clc; clear all; close all;

vid = VideoReader('video.mp4');
frames = vid.NumberOfFrames;
w = vid.Width; h = vid.Height;
mov = read(vid);
fprintf('Video Reading Done \n');


newVid = VideoWriter('car.avi','Grayscale AVI');
newVid.FrameRate = 10;
open(newVid);

for i=26:60
    currentframe = mov(:,:,:,i);
    grayframe = rgb2gray(currentframe);
    writeVideo(newVid,grayframe);
    fprintf('Gray mapping %d/%d \n',i,frames);
end

close(newVid);


