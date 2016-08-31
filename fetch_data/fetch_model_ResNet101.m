
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading model_ResNet-101L...\n');
    urlwrite('https://onedrive.live.com/download?resid=F371D9563727B96F!91963&authkey=!AM-EuzuUJelv9Po', ...
        'models_ResNet-101L.zip');

    fprintf('Unzipping...\n');
    unzip('models_ResNet-101L.zip', '..');

    fprintf('Done.\n');
    delete('models_ResNet-101L.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
