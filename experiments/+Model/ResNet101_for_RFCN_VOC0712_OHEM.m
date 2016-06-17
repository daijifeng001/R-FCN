function model = ResNet101_for_RFCN_VOC0712_OHEM(model)
% ResNet 101layers with OHEM training (finetuned from res3a)

model.solver_def_file        = fullfile(pwd, 'models', 'rfcn_prototxts', 'ResNet-101L_OHEM_res3a', 'solver_80k110k_lr1_3.prototxt');
model.test_net_def_file      = fullfile(pwd, 'models', 'rfcn_prototxts', 'ResNet-101L_OHEM_res3a', 'test.prototxt');

model.net_file               = fullfile(pwd, 'models', 'pre_trained_models', 'ResNet-101L', 'ResNet-101-model.caffemodel');
model.mean_image             = fullfile(pwd, 'models', 'pre_trained_models', 'ResNet-101L', 'mean_image');

end