function [beta,shuf_beta,z_val,residual,beta_name] = twoFactor_full(x,y,shuffle_time)

[glm] = fitglm(x,y,'interactions');

%     histogram(glm.Residuals.raw);

residual = (glm.Residuals.raw);

beta = glm.Coefficients.Estimate';

beta_name = glm.CoefficientNames;

if shuffle_time ~= 0
    
    shuf_beta = zeros(shuffle_time,4);

    for i = 1:shuffle_time
        
        randnum = rand(1)*0.5+0.25;% cut time:0.25-0.75
        
        seg_point = round(randnum*size(x,1));
        
        shuf_x = [x(seg_point+1:end,:); x(1:seg_point,:)];% shuffle distance
        
        [glm] = fitglm(shuf_x,y,'interactions');
        
        shuf_beta(i,:) = glm.Coefficients.Estimate;
        
        
    end
    
    z_val = (beta-mean(shuf_beta,1))./std(shuf_beta,0,1);
    
else
    
    z_val = [];
    
    shuf_beta = [];
end

end

