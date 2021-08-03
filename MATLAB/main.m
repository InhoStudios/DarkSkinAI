folder = 'images';
images = dir(fullfile(folder, '\*.jpg'));

rows = numel(images);

og_vals = zeros(rows, 5);
sog_vals = zeros(rows, 5);
ge_vals = zeros(rows, 5);
gw_vals = zeros(rows, 5);
mrgb_vals = zeros(rows, 5);

for i = 1:rows

    filename = fullfile(folder, images(i).name);
    input_im = uint8(imread(filename));
    
    [aAvg, aDev, bAvg, bDev, hAvg] = calculateColour(input_im);
    
    og_vals(i, 1) = aAvg;
    og_vals(i, 2) = aDev;
    og_vals(i, 3) = bAvg;
    og_vals(i, 4) = bDev;
    og_vals(i, 5) = hAvg;
    
    input_im = double(imread(filename));
    
%     [wR,wG,wB,out1]=shades_of_grey(input_im,1);
%     greyWorld = uint8(out1);
%     imwrite(greyWorld,strcat("gw-", filename));
    greyWorld = uint8(imread(strcat("gw-", filename)));
    
    [aAvg, aDev, bAvg, bDev, hAvg] = calculateColour(greyWorld);
    
    gw_vals(i, 1) = aAvg;
    gw_vals(i, 2) = aDev;
    gw_vals(i, 3) = bAvg;
    gw_vals(i, 4) = bDev;
    gw_vals(i, 5) = hAvg;
    
%     [wR,wG,wB,out2]=shades_of_grey(input_im,-1);
%     maxRGB = uint8(out2);
%     imwrite(maxRGB,strcat("mrgb-", filename));
    maxRGB = uint8(imread(strcat("mrgb-", filename)));

    [aAvg, aDev, bAvg, bDev, hAvg] = calculateColour(maxRGB);
    
    mrgb_vals(i, 1) = aAvg;
    mrgb_vals(i, 2) = aDev;
    mrgb_vals(i, 3) = bAvg;
    mrgb_vals(i, 4) = bDev;
    mrgb_vals(i, 5) = hAvg;
    
    p=5;    % any number between 1 and infinity
%     [wR,wG,wB,out3]=shades_of_grey(input_im,p);
%     shadesOfGrey = uint8(out3);
%     imwrite(shadesOfGrey,strcat("sog-", filename));
    shadesOfGrey = uint8(imread(strcat("sog-", filename)));

    [aAvg, aDev, bAvg, bDev, hAvg] = calculateColour(shadesOfGrey);
    
    sog_vals(i, 1) = aAvg;
    sog_vals(i, 2) = aDev;
    sog_vals(i, 3) = bAvg;
    sog_vals(i, 4) = bDev;
    sog_vals(i, 5) = hAvg;
    
    mink_norm=5;    % any number between 1 and infinity
    sigma=2;        % sigma 
    diff_order=1;   % differentiation order (1 or 2)
%     [wR,wG,wB,out4]=general_cc(input_im,diff_order,mink_norm,sigma);
%     greyEdge = uint8(out4);
%     imwrite(greyEdge,strcat("ge-", filename));
    greyEdge = uint8(imread(strcat("ge-", filename)));

    [aAvg, aDev, bAvg, bDev, hAvg] = calculateColour(greyEdge);

    ge_vals(i, 1) = aAvg;
    ge_vals(i, 2) = aDev;
    ge_vals(i, 3) = bAvg;
    ge_vals(i, 4) = bDev;
    ge_vals(i, 5) = hAvg;
    
    disp(string(i));
end

writematrix(og_vals, "OriginalAB.csv");
writematrix(sog_vals, "ShadesOfGreyAB.csv");
writematrix(mrgb_vals, "maxRGBAB.csv");
writematrix(gw_vals, "GreyWorldAB.csv");
writematrix(ge_vals, "GreyEdgeAB.csv");

cc_deviations = zeros(5, 3);

% histogram(og_vals(:, 1));
% histogram(gw_vals(:, 1));
% histogram(sog_vals(:, 1));
% histogram(mrgb_vals(:, 1));
% histogram(ge_vals(:, 1));
    
og_a = og_vals(:, 1);
og_a_dev = std(og_a(:));

og_b = og_vals(:, 3);
og_b_dev = std(og_b(:));

og_hue = og_vals(:, 5);
og_hue_dev = std(og_hue(:));

gw_a = gw_vals(:, 1);
gw_a_dev = std(gw_a(:));

gw_b = gw_vals(:, 3);
gw_b_dev = std(gw_b(:));

gw_hue = gw_vals(:, 5);
gw_hue_dev = std(gw_hue(:));

sog_a = sog_vals(:, 1);
sog_a_dev = std(sog_a(:));

sog_b = sog_vals(:, 3);
sog_b_dev = std(sog_b(:));

sog_hue = sog_vals(:, 5);
sog_hue_dev = std(sog_hue(:));

mrgb_a = mrgb_vals(:, 1);
mrgb_a_dev = std(mrgb_a(:));

mrgb_b = mrgb_vals(:, 3);
mrgb_b_dev = std(mrgb_b(:));

mrgb_hue = mrgb_vals(:, 5);
mrgb_hue_dev = std(mrgb_hue(:));

ge_a = ge_vals(:, 1);
ge_a_dev = std(ge_a(:));

ge_b = ge_vals(:, 3);
ge_b_dev = std(ge_b(:));

ge_hue = ge_vals(:, 5);
ge_hue_dev = std(ge_hue(:));

% Original, Grey World, maxRGB, Shades of Grey, Grey Edge

cc_deviations(1, 1) = og_a_dev;
cc_deviations(1, 2) = og_b_dev;
cc_deviations(1, 3) = og_hue_dev;
cc_deviations(2, 1) = gw_a_dev;
cc_deviations(2, 2) = gw_b_dev;
cc_deviations(2, 3) = gw_hue_dev;
cc_deviations(3, 1) = mrgb_a_dev;
cc_deviations(3, 2) = mrgb_b_dev;
cc_deviations(3, 3) = mrgb_hue_dev;
cc_deviations(4, 1) = sog_a_dev;
cc_deviations(4, 2) = sog_b_dev;
cc_deviations(4, 3) = sog_hue_dev;
cc_deviations(5, 1) = ge_a_dev;
cc_deviations(5, 2) = ge_b_dev;
cc_deviations(5, 3) = ge_hue_dev;

writematrix(cc_deviations, "ColourConstancyABDeviations.csv");
%%%%%%

function [aAvg, aDev, bAvg, bDev, hAvg] = calculateColour(image)

    img_lab = rgb2lab(image);
    
    img_a = img_lab(:, :, 2);
    img_b = img_lab(:, :, 3);
    
    aAvg = mean(img_a(:));
    bAvg = mean(img_b(:));
    
    aDev = std(img_a(:));
    bDev = std(img_b(:));

    img_hsv = rgb2hsv(image);

    img_h = img_hsv(:, :, 1);
    hAvg = mean(img_h(:));

end