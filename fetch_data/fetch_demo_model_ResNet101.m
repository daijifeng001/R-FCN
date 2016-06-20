
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading demo_models_ResNet-101L...\n');
    urlwrite('https://www.dropbox.com/s/1cvg8ke9nuo9vg3/demo_models_ResNet-101L.zip?dl=1', ...
        'demo_models_ResNet-101L.zip');

    fprintf('Unzipping...\n');
    unzip('demo_models_ResNet-101L.zip', '..');

    fprintf('Done.\n');
    delete('demo_models_ResNet-101L.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
