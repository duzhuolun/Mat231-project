% %% get acceleration of the spring approximation
% AM = zeros(99,4);
% for c = 1:4
%     for r =  1:99
%         if c == 1
%             AM(r,c) = (SM(r + 1,c) + SM(r,c))/2;
%         else
%         
%             AM(r,c) = SM(r + 1,c) - SM(r,c);
%         end
%     end
% end
% %% plot AM(acceleration matrix)
% figure(3);
% for i = 2:4
%     plot(AM(:,1),AM(:,i));
%     hold on;
% end
% hold off;
% %% plot SM with AM for each set
% for i = 2:4
%     figure(i + 2)
%     plot(SM(:,1),SM(:,i), 'Color', 'blue');
%     hold on;
%     plot(AM(:,1),AM(:,i), 'Color', 'red');
%     hold off;
% end
% % we found that this is too much noise for the assitimated acceleration, so
% % we don't use it 