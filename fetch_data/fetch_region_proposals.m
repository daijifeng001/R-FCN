
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading region proposals...\n');
    urlwrite('https://www.dropbox.com/s/gagkulgcif6k1dd/proposals.zip?dl=1', ...
        'proposals.zip');

    fprintf('Unzipping...\n');
    unzip('proposals.zip', '..');

    fprintf('Done.\n');
    delete('proposals.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
