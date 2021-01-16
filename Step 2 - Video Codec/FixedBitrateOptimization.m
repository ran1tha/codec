%% Initialize
clc; clear all; close all;
tic;    %Start Stopwatch
%% Read Video data
vid = VideoReader('limes.avi');     %Import Video
mov = read(vid);                    %Read video
fprintf('Video Reading Done \n');

%% Enter Bitrate in Mbps
bitrate = 15;


%% Optimization Algorithm
flag1 = 0; flag2 =0; id=1; 

if bitrate > 1.42   %Bitrate at Q=1

% For Q < 1: Vary in steps of 0.01
for i=0.1:0.1:1
    if flag1 ==1
        break;
    end
    Q=i;
    rate = OptimizeQ(mov,Q);
    if rate < bitrate
        for j=(i-0.1)+0.01:0.01:i
            Q = j;
            rate = OptimizeQ(mov,Q);
            ratearray(id) =rate; id=id+1;
            if rate < bitrate
                out=Q-0.01;
                rateQ = ratearray(id-1);
                flag1 =1;
                break
            end  
        end
    end
end
% For Q > 1: Vary in steps of 0.1
else
    for i=1:10
    if flag2 ==1
        break;
    end
    Q=i;
    rate = OptimizeQ(mov,Q);
    if rate < bitrate
        for j=(i-1)+0.1:0.1:i
            Q = j;
            rate = OptimizeQ(mov,Q);
            ratearray(id) =rate; id=id+1;
            if rate < bitrate
                out=Q-0.1;
                rateQ = ratearray(id-1);
                flag2 =1;
                break
            end  
        end
    end
    end

end


fprintf('Quantization Optimization Completed \n \n');
fprintf('Optimum Quantization Level: %.3f \n Bitrate at quantization level: %.3f \n',out,rateQ);

toc;