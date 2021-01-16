%% Initialize
clc; clear all; close all;
tic;    %Start Stopwatch
%% Read Video data
vid = VideoReader('limes.avi');     %Import Video
mov = read(vid);                    %Read video
fprintf('Video Reading Done \n');

%% Enter Bitrate in Mbps
bitrate = 1;

%% Optimization Parameters

Q =1;   %Initial guess
stepsize = 1;  %Initial step size
iterations = 10;    %Number of iterations until termination
rate = 20;  %Initial Rate

%% Optimization Algorithm

for i=1:iterations 
    if Q<0 || Q==0 %Stop Algorithm if Q is less than or equal to 0
        fprintf('OPTIMIZATION TERMINATED DUE TO Q<=0 \n');
        break 
    end
    if abs(rate-bitrate) < 0.01 %Stop algorithms for a predefined error tolerance
        fprintf('Optimization Terminated on reaching error tolerance \n');
        break
    end
    rate = OptimizeQ(mov,Q); %Calculate bitrate
    if rate > bitrate        %Step forward of rate > bitrate
        prevQ = Q;           %Store Q value
        stepsize = 0.9*stepsize;    %Adjust Step Size (Move in large steps when going forward - exponential)
        Q = Q+stepsize;             %Step Forward
    else                     %Step backward if rate < bitrate
        prevQ = Q;           %Store Q value
        stepsize = 0.7*stepsize;    %Adjust Step Size (Move in small steps when going forward - exponential)
        Q = Q-stepsize;             %Step backward
    end
    Q_array(i) = prevQ;      %Store Q values
    ratearray(i) = rate;     %Store bitrates
end



fprintf('Quantization Optimization Completed \n \n');
fprintf('Optimum Quantization Level: %.5f \n Bitrate at quantization level: %.3f \n',prevQ,rate);

%% Plots

q_array = 0.1:0.1:10; 
actual_bitrate = [3.446
        2.645
        2.254
       2.0087
        1.834
       1.7181
       1.6203
       1.5379
       1.4778
       1.4227
        1.381
       1.3427
       1.3053
       1.2733
       1.2461
       1.2162
       1.1939
       1.1759
       1.1481
        1.128
       1.1174
       1.0909
       1.0742
       1.0584
       1.0463
       1.0312
        1.017
       1.0052
       0.9936
      0.98181
      0.97066
      0.96269
      0.95235
      0.94397
      0.93223
      0.92646
      0.91473
      0.90937
      0.89982
      0.89448
      0.88527
      0.87676
      0.87403
      0.86865
      0.85713
      0.85418
      0.84761
      0.83822
      0.83406
      0.83144
      0.82563
      0.81566
        0.812
      0.81029
      0.80553
      0.79789
      0.79178
      0.78891
      0.78792
      0.78447
      0.78335
      0.77058
      0.76718
      0.76455
      0.76375
      0.76101
      0.75499
      0.74787
      0.74377
      0.74056
       0.7383
      0.73701
      0.73594
      0.73259
      0.72789
      0.71965
      0.71613
      0.71331
      0.71083
      0.70868
      0.70723
      0.70604
      0.70568
      0.70309
      0.69893
      0.69173
      0.68851
      0.68574
      0.68294
      0.68084
      0.67879
      0.67694
      0.67573
      0.67505
      0.67509
      0.67411
      0.67141
       0.6678
      0.66346
      0.65925]; %Actual bitrate

actual_bitrate = actual_bitrate';

figure;
plot(q_array,actual_bitrate,'k'); %Plot actual data
hold on

stem(Q_array,ratearray,'b'); %Plot iterative steps
stem(Q_array(1),ratearray(1),'y'); %Plot first step
stem(Q_array(end),ratearray(end),'r','LineWidth',2); %Plot first step
plot(q_array(28),actual_bitrate(28),'*g','LineWidth',2)
title('Fixed Bitrate Optimization Procedure'); xlabel('Quantization Level'); ylabel('Bitrate /Mbps');
legend('Actual Bitrate vs Quantization level plot', 'Intermediate Steps','Initialization Step','Optimized Step','Desired Point');
toc;