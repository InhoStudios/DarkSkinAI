folder = 'images';
images = dir(fullfile(folder, '\*.jpg'));

og_vals = zeros(numel(images), 4);
sog_vals = zeros(numel(images), 4);
ge_vals = zeros(numel(images), 4);
gw_vals = zeros(numel(images), 4);
mrgb_vals = zeros(numel(images), 4);

for i = 1:numel(images)
    filename = fullfile(folder, images(i).name);
    input_im = imread(filename);
    
    [aAvg, aDev, bAvg, bDev] = calculateAB(input_im);
    
    og_vals(i, 1) = aAvg;
    og_vals(i, 2) = aDev;
    og_vals(i, 3) = bAvg;
    og_vals(i, 4) = bDev;
    
    evaluateCC(filename);
    
    greyWorld = imread(strcat("gw-", filename));
    
    [aAvg, aDev, bAvg, bDev] = calculateAB(greyWorld);
    
    gw_vals(i, 1) = aAvg;
    gw_vals(i, 2) = aDev;
    gw_vals(i, 3) = bAvg;
    gw_vals(i, 4) = bDev;
    
    maxRGB = imread(strcat("mrgb-", filename));

    [aAvg, aDev, bAvg, bDev] = calculateAB(maxRGB);
    
    mrgb_vals(i, 1) = aAvg;
    mrgb_vals(i, 2) = aDev;
    mrgb_vals(i, 3) = bAvg;
    mrgb_vals(i, 4) = bDev;
    
    shadesOfGrey = imread(strcat("sog-", filename));
    
    [aAvg, aDev, bAvg, bDev] = calculateAB(shadesOfGrey);
    
    sog_vals(i, 1) = aAvg;
    sog_vals(i, 2) = aDev;
    sog_vals(i, 3) = bAvg;
    sog_vals(i, 4) = bDev;
    
    greyEdge = imread(strcat("ge-", filename));

    [aAvg, aDev, bAvg, bDev] = calculateAB(greyEdge);
    
    ge_vals(i, 1) = aAvg;
    ge_vals(i, 2) = aDev;
    ge_vals(i, 3) = bAvg;
    ge_vals(i, 4) = bDev;
    
end
    
og_avg = og_vals(:, 1);
og_avg = og_avg(:);
og_dev = std(og_avg);
og_avg = mean(og_avg);

disp(strcat("Original Avg: ", string(og_avg), ", deviation: ", string(og_dev)));

gw_avg = gw_vals(:, 1);
gw_avg = gw_avg(:);
gw_dev = std(gw_avg);
gw_avg = mean(gw_avg);

disp(strcat("Grey World Avg: ", string(gw_avg), ", deviation: ", string(gw_dev)));

sog_avg = sog_vals(:, 1);
sog_avg = sog_avg(:);
sog_dev = std(sog_avg);
sog_avg = mean(sog_avg);

disp(strcat("Shades of Grey Avg: ", string(sog_avg), ", deviation: ", string(sog_dev)));

mrgb_avg = mrgb_vals(:, 1);
mrgb_avg = mrgb_avg(:);
mrgb_dev = std(mrgb_avg);
mrgb_avg = mean(mrgb_avg);

disp(strcat("maxRGB Avg: ", string(mrgb_avg), ", deviation: ", string(mrgb_dev)));

%%%%%%

function evaluateCC(filename)
    input_im = double(imread(filename));
    
    [wR,wG,wB,out1]=shades_of_grey(input_im,1);
    greyWorld = imread(strcat("gw-", filename));
%     imwrite(greyWorld,strcat("gw-", filename));
    
    [aAvg, aDev, bAvg, bDev] = calculateAB(greyWorld);
%     
%     gw_vals(index, 1) = aAvg;
%     gw_vals(index, 2) = aDev;
%     gw_vals(index, 3) = bAvg;
%     gw_vals(index, 4) = bDev;
    
    [wR,wG,wB,out2]=shades_of_grey(input_im,-1);
    maxRGB = imread(strcat("mrgb-", filename));
%     imwrite(maxRGB,strcat("mrgb-", filename));

    [aAvg, aDev, bAvg, bDev] = calculateAB(maxRGB);
%     
%     mrgb_vals(index, 1) = aAvg;
%     mrgb_vals(index, 2) = aDev;
%     mrgb_vals(index, 3) = bAvg;
%     mrgb_vals(index, 4) = bDev;
    
    p=5;    % any number between 1 and infinity
    [wR,wG,wB,out3]=shades_of_grey(input_im,p);
    shadesOfGrey = imread(strcat("sog-", filename));
%     imwrite(shadesOfGrey,strcat("sog-", filename));

    [aAvg, aDev, bAvg, bDev] = calculateAB(shadesOfGrey);
%     
%     sog_vals(index, 1) = aAvg;
%     sog_vals(index, 2) = aDev;
%     sog_vals(index, 3) = bAvg;
%     sog_vals(index, 4) = bDev;
    
    mink_norm=5;    % any number between 1 and infinity
    sigma=2;        % sigma 
    diff_order=1;   % differentiation order (1 or 2)
    [wR,wG,wB,out4]=general_cc(input_im,diff_order,mink_norm,sigma);
    greyEdge = imread(strcat("ge-", filename));
%     imwrite(greyEdge,strcat("ge-", filename));

    [aAvg, aDev, bAvg, bDev] = calculateAB(greyEdge);
%     
%     ge_vals(index, 1) = aAvg;
%     ge_vals(index, 2) = aDev;
%     ge_vals(index, 3) = bAvg;
%     ge_vals(index, 4) = bDev;
        
end

function [aAvg, aDev, bAvg, bDev] = calculateAB(image)

    img_lab = rgb2lab(image);
    
    img_a = img_lab(:, :, 2);
    img_b = img_lab(:, :, 3);
    img_a = img_a(:);
    img_b = img_b(:);
    
    aAvg = mean(img_a);
    bAvg = mean(img_b);
    
    aDev = std(img_a);
    bDev = std(img_b);
end