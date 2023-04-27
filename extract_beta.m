function [res_beta,trl_num] = extract_beta(data_path,sub_ind,chan_ind,beta_type,suffix,roi_col)
% extract regression beta according sub_ind and chan_ind

if nargin<5
    
    suffix =  '';
    
else
    
    if ~isempty(suffix)
        
        suffix = ['_' suffix];
        
    end
    
end

if nargin<6
    
    roi_col =  2;
    
end

cd(data_path)

res_beta = [];

trl_num = [];

for i = 1:length(sub_ind)
    
    load(['sub' num2str(sub_ind(i)) '_' num2str(chan_ind(i)) suffix])
    
    if ~isempty(retrieval_eopch.beta)
        
        switch beta_type
            
            case 'norm'
                
                res_beta(i,:) = retrieval_eopch.z(:,roi_col);
                
            case 'raw'
                
                res_beta(i,:) = retrieval_eopch.beta(:,roi_col);
                
                
        end
        
    else
        
        res_beta(i,:) =nan;
        
    end
    
end

end



