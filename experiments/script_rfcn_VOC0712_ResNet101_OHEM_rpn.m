function script_rfcn_VOC0712_ResNet101_OHEM_rpn()
% script_rfcn_VOC0712_ResNet101_OHEM_rpn()
% RFCN training and testing with OHEM using ResNet101 model and RPN
% proposals
% --------------------------------------------------------
% R-FCN implementation
% Modified from MATLAB Faster R-CNN (https://github.com/shaoqingren/faster_rcnn)
% Copyright (c) 2016, Jifeng Dai
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------


clc;
clear mex;
clear is_valid_handle; % to clear init_key
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));
%% -------------------- CONFIG --------------------
opts.caffe_version          = 'caffe_rfcn';
opts.gpu_id                 = auto_select_gpu;
active_caffe_mex(opts.gpu_id, opts.caffe_version);

% model
model                       = Model.ResNet101_for_RFCN_VOC0712_OHEM();
% cache name
opts.cache_name             = 'rfcn_VOC0712_ResNet101_OHEM_rpn_resnet101';
% config
conf                        = rfcn_config_ohem('image_means', model.mean_image);
% train/test data
fprintf('Loading dataset...')
dataset                     = [];
dataset                     = Dataset.voc0712_trainval_sp(dataset, 'train', conf.use_flipped, 'resnet101');
dataset                     = Dataset.voc2007_test_sp(dataset, 'test', false, 'resnet101');
fprintf('Done.\n');

% do validation, or not
opts.do_val                 = true; 

%% -------------------- TRAINING --------------------

opts.rfcn_model        = rfcn_train(conf, dataset.imdb_train, dataset.roidb_train, ...
                                'do_val',           opts.do_val, ...
                                'imdb_val',         dataset.imdb_test, ...
                                'roidb_val',        dataset.roidb_test, ...
                                'solver_def_file',  model.solver_def_file, ...
                                'net_file',         model.net_file, ...
                                'cache_name',       opts.cache_name, ...
                                'caffe_version',    opts.caffe_version);
assert(exist(opts.rfcn_model, 'file') ~= 0, 'not found trained model');

%% -------------------- TESTING --------------------
                          rfcn_test(conf, dataset.imdb_test, dataset.roidb_test, ...
                                'net_def_file',     model.test_net_def_file, ...
                                'net_file',         opts.rfcn_model, ...
                                'cache_name',       opts.cache_name,...
                                'ignore_cache',     true);

end
