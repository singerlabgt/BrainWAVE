

function image_list=randomly_pick_images(directory_name,num_images)
    
    imdir = dir(directory_name);
    imdir([imdir.isdir]==1)=[];
    if(isempty(imdir))
        disp(['Error: no images found in ' directory_name]);
        return;
    elseif length(imdir)<num_images
        fprintf(['Error: not enough images\n',num_images]);
        return;
    end
    
    for imnum = 1:length(imdir)%add full path to name
        imdir(imnum).fullname = [imdir(imnum).folder,'/',imdir(imnum).name];
    end
    
    %pick random subset in random order
    rng('shuffle');
    tmprndord = randperm(length(imdir));
    image_list=struct('fullname','name');
    
    for i=1:num_images
        image_list(i).fullname=imdir(tmprndord(i)).fullname;
        image_list(i).name=imdir(tmprndord(i)).name;
    end
    
end