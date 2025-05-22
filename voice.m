[audioIn, fs] = audioread('audio_f1.wav');
% Convert to mono if stereo
if size(audioIn,2) == 2
    audioIn = mean(audioIn, 2);
end
t = (0:length(audioIn)-1)/fs;
figure;
plot(t, audioIn);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original signal');


% framing the signal

frameDuration = 0.02;
frameShift=0.01;

%convert duration into samples

frameLen=round(frameDuration*fs);
frameStep=round(frameShift*fs);

numFrames = floor((length(audioIn)-frameLen)/frameStep)+1;
frames=zeros(frameLen,numFrames);

for i= 1:numFrames
    startIndex=(i-1)*frameStep+1;
    frames(:,i)=audioIn(startIndex:startIndex+frameLen-1);
end

energy = sum(frames.^2);
zcr= sum(abs(diff(sign(frames)))>0);

energy = energy/max(energy);
zcr = zcr/max(zcr);


framesIndex=1:numFrames;
figure;
subplot(2,1,1);
plot(framesIndex,energy);
subplot(2,1,2);
plot(framesIndex,zcr);

zcr_thresh=0.1;
energy_thresh=0.5;

%speech = 1 and silence=0
vad=(energy>energy_thresh)&(zcr<zcr_thresh);

timeFrame = frameShift*(0:numFrames-1);
figure;
subplot(3,1,1);
plot(t,audioIn);
xlabel('time axis');
ylabel('audio amplitude');
title('audio');

subplot(3,1,2);
plot(timeFrame, energy, 'b'); hold on;
yline(energy_thresh, 'r--', 'Threshold');
xlabel('Time (s)');
ylabel('Normalized Energy');
title('Short-Time Energy');

subplot(3,1,3);
plot(timeFrame, zcr, 'g'); hold on;
yline(zcr_thresh, 'r--', 'Threshold');
xlabel('Time (s)');
ylabel('Normalized ZCR');
title('Zero-Crossing Rate');

figure;
stem(timeFrame,vad,'filled');
ylim([-0.2 1.2]);
xlabel('Time (s)');
ylabel('VAD Decision');
title('Voice Activity Detection');
