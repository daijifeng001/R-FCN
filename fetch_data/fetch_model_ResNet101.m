
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading model_ResNet-101L...\n');
    urlwrite('https://www.dropbox.com/s/ev91ss0pyd5h9ix/models_ResNet-101L.zip?dl=1', ...
        'models_ResNet-101L.zip');

    fprintf('Unzipping...\n');
    unzip('models_ResNet-101L.zip', '..');

    fprintf('Done.\n');
    delete('models_ResNet-101L.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
