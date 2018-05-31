clear all;
head; % �w�b�_�t�@�C���̓ǂݍ��݁i�ݒ�l�j

%% �摜�ǂݍ���
disp('���摜��I�����Ă��������D');
filename = uigetfile('*');
ORG = imread(filename);
imagesc(ORG);
axis image; xlabel('x'); ylabel('y');
disp('���摜��\�����܂����D');

%% ��F��
bodyDetector = vision.CascadeObjectDetector('FrontalFaceCART');
bodyDetector.MinSize = [MIN_FACE MIN_FACE];
bodyDetector.MergeThreshold = SENSITIVITY;
bboxBody = step(bodyDetector, ORG);
IBody = insertObjectAnnotation(ORG, 'rectangle',bboxBody,'Upper Body');
imagesc(IBody); axis image;

N = size(bboxBody,1);
disp(strcat(num2str(N),'���̊炪������܂����D'));

for i=1:N % ��ʐώZ�o�ƃ\�[�e�B���O
    bboxBody(i,5) = bboxBody(i,3)*bboxBody(i,4);
end
bboxBody = sortrows(bboxBody,5);
bboxBody = flipud(bboxBody);


disp('�댟�o���N���b�N���Ă��������D�I���͘g�O�i�����j���N���b�N�D');
while(1)
    p = ginput(1);
    if(p(1)<0 | p(2)<0 ) break; end
    j=0;
    for i=1:size(bboxBody,1)
        if(bboxBody(i,1)<p(1) & bboxBody(i,2)<p(2) & ...
                bboxBody(i,1)+bboxBody(i,3)>p(1) & ...
                bboxBody(i,2)+bboxBody(i,4)>p(2))
            j=i;
        end
    end
    if(j>0)
        bboxBody(j,:) = [];
    end
end

N = size(bboxBody,1);
for i=1:N % ��T�C�Y�̓o�^
    F(i) = bboxBody(i,5);
end

disp('�{����\�����܂��D�i�Ŕw�l����1�Ƃ����Ƃ��́j');
M = F/F(N)
disp('�[�x��\�����܂��D');
D = 255./M

bboxBody(:,5)= [];
IBody = insertObjectAnnotation(ORG, 'rectangle',bboxBody,'Upper Body');
imagesc(IBody); axis image;
pause;

%% �̈�摜�̎擾
ORG = imread(filename); % ���摜�̍ēǂݍ���
IMGS = zeros(size(ORG,1),size(ORG,2),N-1);
for i=1:N
    IMG = imcrop(ORG,bboxBody(i,1:4));
    imagesc(IMG);
    axis image; xlabel('x'); ylabel('y');
    q = input('�\������Ă��郁���o�[�̗̈�摜���쐬���܂����H�͂�1�C������0�F');
    if(q==1)
        clipping;
    end
    disp('�l���̈�摜���w�肵�Ă��������D');
    filename = uigetfile('*');
    IMG_a = imread(filename); % ��ʑ�1�̓ǂݍ���
    IMGS(:,:,i) = IMG_a(:,:)>128;
    
    [H,L]=size(ORG) % �摜�̏c���擾0
   L=length(ORG)   % �摜�̉����擾
    
    for j=H:-1:1    % ���ꂼ��̐l���̈�̑��������o
        A=IMG_a(j,:);
        
        if all(A<200)
        else % �z��v�f��255�̏ꍇ�C�s���擾���J��Ԃ����I��
            F(i)=j
            break
        end
    end
end



%% �[�x�̎Z�o
IMG_b = IMGS(:,:,N-1)*D(N-1);
for i=N-2:-1:1
    IMG_b = IMG_b + (IMG_b==0 & IMGS(:,:,i))*D(i);
end
IMG_b = IMG_b + (IMG_b==0)*255; % �w�i�̐[�x��255

disp('�l���̐[�x�摜��\�����܂����D');

imagesc(IMG_b); colormap(gray); colorbar;
axis image; xlabel('x'); ylabel('y');
pause;

imshow(ORG)
%{
disp('�n�ʂ̗̈�摜���쐬���܂��D');
DetectHor;
%}
disp('�n�ʗ̈�摜���w�肵�Ă��������D');
filename = uigetfile('*');
IMG_g = imread(filename); % �n�ʗ̈�̓ǂݍ���

for j=1:1:H % �����������o
    B=IMG_g(j,:);
    
    if all(B<200)
    else
        Ho=j; % �z��v�f��255�̏ꍇ�C�s���擾���J��Ԃ����I��
        break
    end
end

W=H-Ho;    % �摜���[���琅�����܂ł̗�

T=255/W;


for l=1:1:N+1 % ��ʑ̊Ԃ̗񐔎擾
    if l==1 % �摜���[����őO�l��
        Di(l)=H-F(l);
    elseif l==N+1   % �Ŕw�l�����琅����
        Di(l)=F(l-1)-Ho;
    else % �l����
        Di(l)=F(l-1)-F(l);
    end
end

C=0;
%��ʑ̂̐[�x�l���ω����āA5�l���̐��m�Ȑ[�x�l�������镔���B(2018/5/28)
for k=1:1:N % ��ʑ̂̐[�x�l�ύX
    D(k)=Di(k)*T+C;
    C=D(k);
end
%{
disp('�n�ʗ̈�摜���w�肵�Ă��������D');
filename = uigetfile('*');
IMG_h = imread(filename); % �n�ʗ̈�̓ǂݍ���
%}
IMG_h=im2double(IMG_g);


%�ǂ�����Ĕw�i��\��t����񂾂낤�A�A�A


IMG_c = IMGS(:,:,N-1)*D(N-1);

for i=N:-1:1
    IMG_c = IMG_c + IMG_h+(IMG_c==0 & IMGS(:,:,i))*D(i);
end

IMG_c = IMG_c +IMG_h+(IMG_c==256 & IMGS(:,:,i))*D(i); % �w�i�̐[�x��255
disp('�ύX��̐l���[�x�摜��\�����܂����D�[�x�摜��ۑ����܂��D');
imagesc(IMG_c); colormap(gray); colorbar;
axis image; xlabel('x'); ylabel('y');
pause;
imwrite(uint8(IMG_c),'de.jpg');
%{
%�ΐ��ϊ��ɂ��[�x�}�b�v�쐬(�n�ʂ̃O���f�[�V�������ł�����폜)
IMG_d=log(IMG_c)
disp('�ύX��̐l���[�x�摜��\�����܂����D�[�x�摜��ۑ����܂��D');
imagesc(IMG_d); colormap(gray); colorbar;
axis image; xlabel('x'); ylabel('y');
pause;

imwrite(uint8(IMG_d),'dep.jpg'); % �摜�̕ۑ�
%}



% %% ����p�摜����
% CLPS = zeros(size(ORG,1),size(ORG,2),(N-1)*3);
% MSKS = zeros(size(ORG,1),size(ORG,2),N-1);
% for i=1:N-1
%     mv_x = fix(MV_MAX*(255-D(i))/255);
%     IMG_c = ORG;
%     IMG_c(:,:,1) = IMGS(:,:,i); IMG_c(:,:,2) = IMGS(:,:,i); IMG_c(:,:,3) = IMGS(:,:,i);
%     IMG_c = IMG_c.*ORG;
%     IMG_c = imtranslate(IMG_c,[mv_x, 0]);
%     CLPS(:,:,(i-1)*3+1) = IMG_c(:,:,1);
%     CLPS(:,:,(i-1)*3+2) = IMG_c(:,:,2);
%     CLPS(:,:,(i-1)*3+3) = IMG_c(:,:,3);
%     MSKS(:,:,i) = imtranslate(IMGS(:,:,i),[mv_x, 0]);
% end
%
% % �摜�̍���
% ORG2 = ORG;
% CLP = ORG;
% for i=N-1:-1:1
%     CLP(:,:,1) = CLPS(:,:,(i-1)*3+1);
%     CLP(:,:,2) = CLPS(:,:,(i-1)*3+2);
%     CLP(:,:,3) = CLPS(:,:,(i-1)*3+3);
%     MSK = (IMGS(:,:,i)+MSKS(:,:,i))==0;
%     IMG_c(:,:,1) = MSK; IMG_c(:,:,2) = MSK; IMG_c(:,:,3) = MSK;
%     ORG2 = IMG_c.*ORG2+CLP;
% end
% disp('����摜��\�����܂����D');
% imagesc(ORG2);
% axis image; xlabel('x'); ylabel('y');
% pause;
%
% IMG_L = ORG2;
% imwrite(IMG_L,'left.png'); % �摜�̕ۑ�
%
% %% �E��p�摜����
% CLPS = zeros(size(ORG,1),size(ORG,2),(N-1)*3);
% MSKS = zeros(size(ORG,1),size(ORG,2),N-1);
% for i=1:N-1
%     mv_x = fix(MV_MAX*(255-D(1))/255)*-1;
%     IMG_d = ORG;
%     IMG_d(:,:,1) = IMGS(:,:,i); IMG_d(:,:,2) = IMGS(:,:,i); IMG_d(:,:,3) = IMGS(:,:,i);
%     IMG_d = IMG_d.*ORG;
%     IMG_d = imtranslate(IMG_d,[mv_x, 0]);
%     CLPS(:,:,(i-1)*3+1) = IMG_d(:,:,1);
%     CLPS(:,:,(i-1)*3+2) = IMG_d(:,:,2);
%     CLPS(:,:,(i-1)*3+3) = IMG_d(:,:,3);
%     MSKS(:,:,i) = imtranslate(IMGS(:,:,i),[mv_x, 0]);
% end
%
% % �摜�̍���
% ORG2 = ORG;
% CLP = ORG;
% for i=N-1:-1:1
%     CLP(:,:,1) = CLPS(:,:,(i-1)*3+1);
%     CLP(:,:,2) = CLPS(:,:,(i-1)*3+2);
%     CLP(:,:,3) = CLPS(:,:,(i-1)*3+3);
%     MSK = (IMGS(:,:,i)+MSKS(:,:,i))==0;
%     IMG_d(:,:,1) = MSK; IMG_d(:,:,2) = MSK; IMG_d(:,:,3) = MSK;
%     ORG2 = IMG_d.*ORG2+CLP;
% end
% disp('�E��摜��\�����܂����D');
% imagesc(ORG2);
% axis image; xlabel('x'); ylabel('y');
% pause;
%
% IMG_R = ORG2;
% imwrite(IMG_R,'right.png'); % �摜�̕ۑ�
%
% %% �A�i�O���t�摜�̐���
% IMG_e = stereoAnaglyph(IMG_L, IMG_R);
% imwrite(IMG_e,'anaglyph.png'); % �摜�̕ۑ�
% disp('�A�i�O���t�摜��\�����܂����D');
% imagesc(IMG_e);
% axis image; xlabel('x'); ylabel('y');
