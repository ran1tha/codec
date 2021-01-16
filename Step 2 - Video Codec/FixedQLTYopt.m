%% Initialize
clc; clear all; close all;
tic;    %Start Stopwatch
%% Read Video data
vid = VideoReader('limes.avi');     %Import Video
mov = read(vid);                    %Read video
fprintf('Video Reading Done \n');
format short g
%% Input Quality as a Percentage [0-100] : 0-Lowest | 100-Highest
quality = 65;


%% 

desiredVQM = (100-quality)/100;         %Convert Quality Value to VQM, since VQM is a measure of distortion

%% Optimization Algorithm

%Optimization Parameters
Q =7; %Initial Guess
stepsize = 1; %Initial Step size
iterations = 10;    %Number of iterations until algorithm termination
vqm = 1; %Initial VQM

for i=1:iterations 
    if Q<0 || Q==0 %Stop Algorithm if Q is less than or equal to 0
        fprintf('OPTIMIZATION TERMINATED DUE TO Q<=0 \n');
        break 
    end
    if abs(vqm-desiredVQM) < 0.001 %Stop algorithms for a predefined error tolerance
        fprintf('Optimization Terminated on reaching error tolerance \n');
        break
    end
    [vqm,bitrate,decoded] = OptimizeBR(mov,Q); %Calculate bitrate
    if vqm < desiredVQM        %Step forward of rate > bitrate
        prevQ = Q;           %Store Q value
        stepsize = 0.5*stepsize;    %Adjust Step Size - Large Steps Forward (Exponential)
        Q = Q+stepsize;             %Step Forward
    else                     %Step backward if rate < bitrate
        prevQ = Q;           %Store Q value
        stepsize = 0.5*stepsize;    %Adjust step size - Small Steps Backward (Exponential)
        Q = Q-stepsize;             %Step backward
    end
    Q_array(i) = prevQ;      %Store Q values
    ratearray(i) = bitrate;     %Store bitrates
    vqmarray(i) = vqm;      %Store VQM
end


outqual = 100-100*vqm;                  %Calculate output quality from VQM
fprintf('Quantization Optimization Completed \n \n');
fprintf('Quality: %.3f%%\n',outqual);      %Print Output Quality
fprintf('Optimum Quantization Level: %.5f \n Bitrate at quantization level: %.3f \n',prevQ,bitrate);

%% Output the optimized video
implay(uint8(decoded));

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

actual_vqm = [0.31075
      0.31083
      0.31096
      0.31111
      0.31117
      0.31163
      0.31207
      0.31185
      0.31244
      0.31258
      0.31251
      0.31377
      0.31359
      0.31473
      0.31494
      0.31452
      0.31653
      0.31935
      0.31806
      0.31643
         0.32
      0.31769
      0.31718
       0.3188
      0.32285
      0.32337
      0.32109
      0.31983
      0.32215
      0.32603
      0.32425
      0.32461
      0.32899
      0.32354
      0.32646
      0.32433
      0.32828
      0.32571
      0.33612
      0.33294
      0.33162
       0.3292
      0.33227
      0.34009
       0.3313
       0.3357
      0.33532
      0.34056
      0.33671
      0.33485
      0.34582
      0.34229
      0.33615
      0.34134
      0.33831
       0.3861
      0.33976
      0.34539
      0.34512
      0.34156
      0.40682
      0.36459
      0.34001
      0.35551
       0.3507
      0.34764
      0.36155
       0.4071
      0.36791
      0.34453
      0.36125
      0.35762
       0.3553
       0.3547
      0.37235
      0.43879
      0.39614
      0.35646
      0.35015
      0.36857
      0.36693
      0.36426
      0.36319
      0.36314
      0.38573
      0.47648
      0.42983
      0.40232
      0.37116
      0.35881
      0.36826
       0.3775
      0.37624
      0.37629
      0.37511
      0.37371
      0.37936
      0.39793
      0.52234
      0.49501];

actual_vqm = actual_vqm';
actual_vqm = sort(actual_vqm);

figure;
plot(actual_vqm,actual_bitrate,'k'); %Plot actual data
hold on

stem(vqmarray,ratearray,'b'); %Plot iterative steps
stem(vqmarray(1),ratearray(1),'y'); %Plot first step
stem(vqmarray(end),ratearray(end),'r','LineWidth',2); %Plot first step
title('Rate Distortion Curve for Fixed Quality level Optimization Procedure');
xlabel('Distortion /VQM'); ylabel('Bitrate /Mbps'); %xlim([0.3 0.34]);
legend('Rate Distortion Curve', 'Intermediate Steps','Initialization Step','Optimized Step');

toc;