% for i = 0:17
%    fname = strcat('img', string(i), '.jpg');
%    applyCC(fname);
% end

images = dir("images\*.jpg")

for i = 1:numel(images);
    filename = images(i).name;
    applyCC(filename);
end

function rgbImage = balanceImg(path)
    rgbImage = imread(path);
    grayImage = rgb2gray(rgbImage); 
    redChannel = rgbImage(:, :, 1);
    greenChannel = rgbImage(:, :, 2);
    blueChannel = rgbImage(:, :, 3);
    meanR = mean2(redChannel);
    meanG = mean2(greenChannel);
    meanB = mean2(blueChannel);
    meanGray = mean2(grayImage);
    redChannel = uint8(double(redChannel) * 1.31 * meanGray / meanR);
    greenChannel = uint8(double(greenChannel) * meanGray / meanG);
    blueChannel = uint8(double(blueChannel) * 0.87 * meanGray / meanB);
    rgbImage = cat(3, redChannel, greenChannel, blueChannel);
end

function applyCC(fileName)
    input_im = double(imread(fileName));
    
    [wR,wG,wB,out1]=general_cc(input_im,0,1,0);
    imwrite(uint8(out1),strcat("gw-", fileName));
    
    [wR,wG,wB,out2]=general_cc(input_im,0,-1,0);
    imwrite(uint8(out2),strcat("mrgb-", fileName));
    
    mink_norm=5;    % any number between 1 and infinity
    [wR,wG,wB,out3]=general_cc(input_im,0,mink_norm,0);
    imwrite(uint8(out3),strcat("sog-", fileName));
    
    mink_norm=5;    % any number between 1 and infinity
    sigma=2;        % sigma 
    diff_order=1;   % differentiation order (1 or 2)
    [wR,wG,wB,out4]=general_cc(input_im,diff_order,mink_norm,sigma);
    imwrite(uint8(out4),strcat("ge-", fileName));
end
    
function transImg = applyLut(imgPath, lutPath)
    img = imread(imgPath);
    lut = dlmread(lutPath, ' ', 8, 0);
    [img_lut] = imlut(img, lut, '3D', 'standard');
    imshow(img_lut);
end