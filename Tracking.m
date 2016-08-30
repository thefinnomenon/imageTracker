%%%%%%%%%%%%%%%%%%%%%%%
%% CS370 Assignment 6
%% Tracking
%% Author: Christopher Finn
%% Date: 11/28/2012
%%%%%%%%%%%%%%%%%%%%%%%%

listing = dir('david/imgs/');
numFiles = size(listing,1);
i = 1;
alpha = 0.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process First Image & Bounding Box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = listing(i+4).name;
inputfile = strcat('david/imgs/', filename);
im=double(imread(inputfile));
colormap(gray);
imagesc(im);
[x,y] = ginput(2);
x_offset = round((x(2) - x(1))/2);
y_offset = round((y(2) - y(1))/2);
center = round([(y(1)+y_offset),(x(1)+x_offset)]);
box = round([center(1)-y_offset,center(1)+y_offset,center(2)-x_offset,center(2)+x_offset]);
template = im(box(1):box(2),box(3):box(4));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = i + 1;
filename = listing(i+4).name;
inputfile = strcat('david/imgs/', filename);
im=double(imread(inputfile));

index = 1;
while(i<=numFiles)
    %%%%%%%%%%%%%%%%%%%%%
    %% Correlation
    %%%%%%%%%%%%%%%%%
    corr_result = filter2(template,im);
    ones_filter = ones(size(template,1),size(template,2));
    im_norm = im.^2;
    im_norm = filter2(ones_filter,im_norm);
    im_norm = im_norm.^(0.5);
    corr_result = corr_result./im_norm;
    %%%%%%%%%%%%%%%%%%%%
    %% Figure Update
    %%%%%%%%%%%%%%%%
    %{
    subplot(1,3,1);
    imagesc(im);
    title('Input');
    hold on;
    plot(center(2),center(1),'o'); 
    hold off; 
    rectangle('Position',[box(3) box(1) x_offset*2 y_offset*2],'EdgeColor',[1 0 0],'LineWidth',1);
    subplot(1,3,2);
    colormap(gray);
    imagesc(template);
    title('Filter');
    subplot(1,3,3);
    colormap(gray);
    imagesc(corr_result);
    title('Output');
    drawnow;
    %}
    if(mod(i,5) == 0 && i<=100) % Plot every 5th image upto 100
        subplot(5,4,index);
        imagesc(im);
        title(['Frame ',num2str(i)]);
        hold on;
        plot(center(2),center(1),'o'); 
        hold off; 
        rectangle('Position',[box(3) box(1) x_offset*2 y_offset*2],'EdgeColor',[1 0 0],'LineWidth',1);
        axis tight;
        axis off;
        drawnow;
        index = index + 1;
    end
    %%%%%%%%%%%%%%%%%%%%
    %% Center Update
    %%%%%%%%%%%%%%%%
    [maxCorr,ind] = max(corr_result(:));
    [m,n] = ind2sub(size(corr_result),ind);
    center = [m,n];
    %%%%%%%%%%%%%%%%
    %% Bounding Box Update
    %%%%%%%%%%%%%%%%%%
    box = round([center(1)-y_offset,center(1)+y_offset,center(2)-x_offset,center(2)+x_offset]);
    if(box(1)<1)
        box(1) = 1;
    end
    if(box(3)<1)
        box(3) = 1;
    end
    if(box(2)>size(im,1))
       box(2) = size(im,1);
    end
    if(box(4)>size(im,2))
        box(4) = size(im,2);
    end 
    %%%%%%%%%%%%%%%%%%%%%
    %% Image Update
    %%%%%%%%%%%%%%%%%
    i = i + 1;
    filename = listing(i+4).name;
    inputfile = strcat('david/imgs/', filename);
    im=double(imread(inputfile));
    %%%%%%%%%%%%%%%%%%%%%
    %% Template Update
    %%%%%%%%%%%%%%%%%
    old_template = template;
    template = alpha*old_template + (1-alpha)*(im(box(1):box(2),box(3):box(4)));
    %%%%%%%%%%%%%%%%%
end