function dataset = voc2007_test_sp(dataset, usage, use_flip, extension)
% Pascal voc 2007 test set with *pre-computed* RPN proposals (trained with ResNet50 or ResNet101)  
% extension = "resnet50" or "resnet101" for specifying pre-computed RPN proposals  
% set opts.imdb_train opts.roidb_train  


% change to point to your devkit install
devkit                      = voc2007_devkit();

switch usage
    case {'train'}
        dataset.imdb_train    = {  imdb_from_voc(devkit, 'test', '2007', use_flip) };
        dataset.roidb_train   = cellfun(@(x) x.roidb_func(x, 'with_self_proposal', true, 'extension', extension), dataset.imdb_train, 'UniformOutput', false);
    case {'test'}
        dataset.imdb_test     = imdb_from_voc(devkit, 'test', '2007', use_flip);
        dataset.roidb_test    = dataset.imdb_test.roidb_func(dataset.imdb_test, 'with_self_proposal', true, 'extension', extension);
    otherwise
        error('usage = ''train'' or ''test''');
end

end