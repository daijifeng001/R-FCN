function p = new_parpool(number)    
    
    if ~exist('number', 'var')
        number = cpu_cores();
    end

    if ~isempty(gcp('nocreate'))
        delete(gcp);
    end
    p = parpool(number);   
end