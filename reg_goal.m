function [beta,shuf_beta,z_val,residual,beta_name] = reg_goal(x,y,shuffle_time)

[glm] = fitglm(x,y);

%     histogram(glm.Residuals.raw);

residual = (glm.Residuals.raw);

beta = glm.Coefficients.Estimate';

beta_name = glm.CoefficientNames;

if shuffle_time ~= 0
    
    shuf_beta = zeros(shuffle_time,length(beta_name));

    for i = 1:shuffle_time
        
        randnum = rand(1)*0.5+0.25;% cut time:0.25-0.75
        
        seg_point = round(randnum*size(x,1));
        
        shuf_x = [x(seg_point+1:end,:); x(1:seg_point,:)];% shuffle distance
        
        [shuf_glm] = fitglm(shuf_x,y);
        
        shuf_beta(i,:) = shuf_glm.Coefficients.Estimate';
        
%         all_rand(i) = randnum;
        
    end
    
    z_val = (beta-mean(shuf_beta))./std(shuf_beta);
    
else
    
    z_val = [];
    
    shuf_beta = [];
    
end

end













