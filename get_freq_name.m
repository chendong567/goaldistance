function [freq, condname] = get_freq_name(cond)

switch cond
    
    case 'wavelet'
        
        s=0:49;f=@(x)2*10^(0.0383*x);freq=arrayfun(f,s);
        
        condname = round(10*freq)./10;
        
        condname = num2cell(condname);
        
        freq = round((freq).*100)./100;
        
    case 'bandpass'
        
        freq = [4 8; 4 9; 4 10;4 12;5 9; 5 10; 5 11; 5 12;...
            
        6 9; 6 10;6 11; 6 12;7 13; 3 10; 4 14; 3 12; ...
        
        1 4; 1 5;2 5; 2 6; 1 6; 3 7;10 16;12 16;15 30;30 100;30 60;60 90;30 90;80 150;70 150];
    
    for i = 1:length(freq)
        
        condname{i} = [num2str(freq(i,1)) '-' num2str(freq(i,2))];
        
    end
    

end


end