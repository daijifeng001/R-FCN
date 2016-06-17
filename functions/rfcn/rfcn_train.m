function save_model_path = rfcn_train(conf, imdb_train, roidb_train, varargin)
% save_model_path = rfcn_train(conf, imdb_train, roidb_train, varargin)
% --------------------------------------------------------
% R-FCN implementation
% Modified from MATLAB Faster R-CNN (https://github.com/shaoqingren/faster_rcnn)
% Copyright (c) 2016, Jifeng Dai
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

%% inputs
    ip = inputParser;
    ip.addRequired('conf',                              @isstruct);
    ip.addRequired('imdb_train',                        @iscell);
    ip.addRequired('roidb_train',                       @iscell);
    ip.addParamValue('do_val',          false,          @isscalar);
    ip.addParamValue('imdb_val',        struct(),       @isstruct);
    ip.addParamValue('roidb_val',       struct(),       @isstruct);
    ip.addParamValue('val_iters',       500,            @isscalar); 
    ip.addParamValue('val_interval',    5000,           @isscalar); 
    ip.addParamValue('snapshot_interval',...
                                        10000,          @isscalar);
    ip.addParamValue('solver_def_file', fullfile(pwd, 'models', 'rfcn_prototxts', 'ResNet-50L_res3a', 'solver_80k120k_lr1_3.prototxt'), ...
                                                        @isstr);
    ip.addParamValue('net_file',        fullfile(pwd, 'models', 'pre_trained_models', 'ResNet-50L', 'ResNet-50-model.caffemodel'), ...
                                                        @isstr);
    ip.addParamValue('cache_name',      'ResNet-50L_res3a', ...
                                                        @isstr);
    ip.addParamValue('caffe_version',   'Unkonwn',      @isstr);
    
    ip.parse(conf, imdb_train, roidb_train, varargin{:});
    opts = ip.Results;
    
%% try to find trained model
    imdbs_name = cell2mat(cellfun(@(x) x.name, imdb_train, 'UniformOutput', false));
    cache_dir = fullfile(pwd, 'output', 'rfcn_cachedir', opts.cache_name, imdbs_name);
    save_model_path = fullfile(cache_dir, 'final');
    if exist(save_model_path, 'file')
        return;
    end
    
%% init
    % set random seed
    prev_rng = seed_rand(conf.rng_seed);
    caffe.set_random_seed(conf.rng_seed);
    
    % init caffe solver
    mkdir_if_missing(cache_dir);
    caffe_log_file_base = fullfile(cache_dir, 'caffe_log');
    caffe.init_log(caffe_log_file_base);
    caffe_solver = caffe.Solver(opts.solver_def_file);
    caffe_solver.net.copy_from(opts.net_file);

    % init log
    timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
    mkdir_if_missing(fullfile(cache_dir, 'log'));
    log_file = fullfile(cache_dir, 'log', ['train_', timestamp, '.txt']);
    diary(log_file);

    % set gpu/cpu
    if conf.use_gpu
        caffe.set_mode_gpu();
    else
        caffe.set_mode_cpu();
    end
    
    
    disp('conf:');
    disp(conf);
    disp('opts:');
    disp(opts);
    
%% making tran/val data
    fprintf('Preparing training data...');
    [image_roidb_train, bbox_means, bbox_stds] = rfcn_prepare_image_roidb(conf, opts.imdb_train, opts.roidb_train);
    fprintf('Done.\n');
    
    if opts.do_val
        fprintf('Preparing validation data...');
        [image_roidb_val] = rfcn_prepare_image_roidb(conf, opts.imdb_val, opts.roidb_val, bbox_means, bbox_stds);
        fprintf('Done.\n');

        % fix validation data
        shuffled_inds_val = generate_random_minibatch([], image_roidb_val, conf.ims_per_batch);
        shuffled_inds_val = shuffled_inds_val(randperm(length(shuffled_inds_val), opts.val_iters));
    end
    
%% training
    shuffled_inds = [];
    train_results = [];  
    val_results = [];  
    iter_ = caffe_solver.iter();
    max_iter = caffe_solver.max_iter();
    
    p = new_parpool(1);
    parfor i=1:1
        seed_rand(conf.rng_seed);
    end
    [shuffled_inds, sub_db_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, conf.ims_per_batch);
    parHandle = parfeval(p, @rfcn_get_minibatch, 1, conf, image_roidb_train(sub_db_inds));
    tic
    while (iter_ < max_iter)
        caffe_solver.net.set_phase('train');

        % generate minibatch training data
        % gather date
        [~, net_inputs] = fetchNext(parHandle);

        % generate minibatch training data
        % generate data asynchronously 
        [shuffled_inds, sub_db_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, conf.ims_per_batch);
        parHandle = parfeval(p, @rfcn_get_minibatch, 1, conf, image_roidb_train(sub_db_inds));

        caffe_solver.net.reshape_as_input(net_inputs);

        % one iter SGD update
        caffe_solver.net.set_input_data(net_inputs);
        caffe_solver.step(1);
        
        rst = caffe_solver.net.get_output();
        train_results = parse_rst(train_results, rst);
            
        % do valdiation per val_interval iterations
        if ~mod(iter_, opts.val_interval)
            if opts.do_val
                caffe_solver.net.set_phase('test');                
                for i = 1:length(shuffled_inds_val)
                    sub_db_inds = shuffled_inds_val{i};
                    net_inputs = rfcn_get_minibatch(conf, image_roidb_val(sub_db_inds));
                    caffe_solver.net.reshape_as_input(net_inputs);
                    
                    caffe_solver.net.forward(net_inputs);
                    
                    rst = caffe_solver.net.get_output();
                    val_results = parse_rst(val_results, rst);
                end
            end
            
            show_state(iter_, train_results, val_results);
            toc;tic;
            train_results = [];
            val_results = [];
            diary; diary; % flush diary
        end
        
        % snapshot
        if ~mod(iter_, opts.snapshot_interval)
            snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
        end
        
        iter_ = caffe_solver.iter();
    end
    
    % final snapshot
    snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, sprintf('iter_%d', iter_));
    save_model_path = snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, 'final');

    diary off;
    caffe.reset_all(); 
    rng(prev_rng);
end

function [shuffled_inds, sub_inds] = generate_random_minibatch(shuffled_inds, image_roidb_train, ims_per_batch)

    % shuffle training data per batch
    if isempty(shuffled_inds)
        % make sure each minibatch, only has horizontal images or vertical
        % images, to save gpu memory
        
        hori_image_inds = arrayfun(@(x) x.im_size(2) >= x.im_size(1), image_roidb_train, 'UniformOutput', true);
        vert_image_inds = ~hori_image_inds;
        hori_image_inds = find(hori_image_inds);
        vert_image_inds = find(vert_image_inds);
        
        % random perm
        lim = floor(length(hori_image_inds) / ims_per_batch) * ims_per_batch;
        hori_image_inds = hori_image_inds(randperm(length(hori_image_inds), lim));
        lim = floor(length(vert_image_inds) / ims_per_batch) * ims_per_batch;
        vert_image_inds = vert_image_inds(randperm(length(vert_image_inds), lim));
        
        % combine sample for each ims_per_batch 
        hori_image_inds = reshape(hori_image_inds, ims_per_batch, []);
        vert_image_inds = reshape(vert_image_inds, ims_per_batch, []);
        
        shuffled_inds = [hori_image_inds, vert_image_inds];
        shuffled_inds = shuffled_inds(:, randperm(size(shuffled_inds, 2)));
        
        shuffled_inds = num2cell(shuffled_inds, 1);
    end
    
    if nargout > 1
        % generate minibatch training data
        sub_inds = shuffled_inds{1};
        assert(length(sub_inds) == ims_per_batch);
        shuffled_inds(1) = [];
    end
end

function model_path = snapshot(caffe_solver, bbox_means, bbox_stds, cache_dir, file_name)
    bbox_pred_layer_name = 'rfcn_bbox';
    weights = caffe_solver.net.params(bbox_pred_layer_name, 1).get_data();
    biase = caffe_solver.net.params(bbox_pred_layer_name, 2).get_data();
    weights_back = weights;
    biase_back = biase;
 
    rep_time = size(weights, 4)/length(bbox_means(:));
    
    bbox_stds_flatten = bbox_stds';
    bbox_stds_flatten = bbox_stds_flatten(:);
    bbox_stds_flatten = repmat(bbox_stds_flatten, [1,rep_time])';
    bbox_stds_flatten = bbox_stds_flatten(:);
    bbox_stds_flatten = permute(bbox_stds_flatten, [4,3,2,1]);
    
    bbox_means_flatten = bbox_means';
    bbox_means_flatten = bbox_means_flatten(:);
    bbox_means_flatten = repmat(bbox_means_flatten, [1,rep_time])';
    bbox_means_flatten = bbox_means_flatten(:);
    bbox_means_flatten = permute(bbox_means_flatten, [4,3,2,1]);
    
    % merge bbox_means, bbox_stds into the model
    weights = bsxfun(@times, weights, bbox_stds_flatten); % weights = weights * stds; 
    biase = biase .* bbox_stds_flatten(:) + bbox_means_flatten(:); % bias = bias * stds + means;
    
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 1, weights);
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 2, biase);

    model_path = fullfile(cache_dir, file_name);
    caffe_solver.net.save(model_path);
    fprintf('Saved as %s\n', model_path);
    
    % restore net to original state
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 1, weights_back);
    caffe_solver.net.set_params_data(bbox_pred_layer_name, 2, biase_back);
end

function show_state(iter, train_results, val_results)
    fprintf('\n------------------------- Iteration %d -------------------------\n', iter);
    fprintf('Training : accuracy %.3g, loss (cls %.3g, reg %.3g)\n', ...
        mean(train_results.accuarcy.data), ...
        mean(train_results.loss_cls.data), ...
        mean(train_results.loss_bbox.data));
    if exist('val_results', 'var') && ~isempty(val_results)
        fprintf('Testing  : accuracy %.3g, loss (cls %.3g, reg %.3g)\n', ...
            mean(val_results.accuarcy.data), ...
            mean(val_results.loss_cls.data), ...
            mean(val_results.loss_bbox.data));
    end
end
