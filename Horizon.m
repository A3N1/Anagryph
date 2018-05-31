disp('���摜��I�����Ă��������D');
filename = uigetfile('*');
ORG = imread(filename);
imagesc(ORG);
axis image; xlabel('x'); ylabel('y');
disp('���摜��\�����܂����D');

disp('�n�������N���b�N���Ă��������D')
[M,MyHeight] = ginput(1);  % �N���b�N�|�C���g��y���W���擾
MyHeight=round(MyHeight); % �z��͐��̐����Ȃ̂Ŋۂߍ��� MyHeight:= �������ʒu(height,px)

[H,L]=size(ORG) % �摜�̏c���擾

L=length(ORG)   % �摜�̉����擾
hold on, plot([0 L],[MyHeight MyHeight],'b')
disp('�n������ݒ肵�܂����D')

G=zeros(H,L);   % ORG�Ɠ����T�C�Y�̔z��𐶐�

%grad = 1;
for i=H:-1:1 % �摜���[���琅�����܂ł𔒂ɂ���
    %B=G(i,:);
    if find(i <= MyHeight)
        G(i,:)=255;
    else
        %G(i,:)=grad;
        %if (grad < 128)
        %    grad = grad +1; 
        %end
        G(i,:) = convDepth(i,MyHeight);
    end
end
pause;
disp('�ύX��̐l���[�x�摜��\�����܂����D�[�x�摜��ۑ����܂��D');
imagesc(G); colormap(gray); colorbar;
axis image; xlabel('x'); ylabel('y');
pause;
imwrite(uint8(G),'ground.png');% �摜�̕ۑ�

function y = convDepth(H,Ho)
    %y = cast(255/(H - H0), 'uint8');
    y = cast(4.04* sqrt(3456-H), 'uint8');
    
    if y > 255
        y = 255;
    end
end

