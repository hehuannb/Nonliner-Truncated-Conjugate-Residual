function [sol,FVAL, history] = nltgcr_opt(fun,sol,lb,tol,itmax, restart)
%     To minimize this function with the gradient provided, modify
%     the function myfun so the gradient is the second output argument:
%        function [f,g] = fun(x)
%         f = sin(x) + 3;
%         g = cos(x);
format long
history = [];
n = length(sol); 
%%-------------------- define P and AP to contain zero columns
P  = zeros(n,lb);
AP = zeros(n,lb);
%%--------------------get initial residual vector and norm 
r = FF(sol);         
rho = norm(r);
tol1 = tol*rho; 
% ep = epsf*norm(sol)/rho;
%  Ar = (FF(sol-ep*r) - r)/ep;
%% --------------Here I use complex diff
ep = 1d-12;
imagi= sqrt(-1);
Ar = imag(FF(sol-ep*r*imagi)/ep);
t = norm(Ar);
t = 1.0 / t;
P(:,1) = t * r;
AP(:,1) = t*Ar;
it = 0;
FVAL = [fun(sol)];
%%
fprintf(1,' it %d  rho %10.3e \n', it,rho);
if (rho <= 0.0)
return
end
%%--------------------get abs residual norm tol from 1st residual norm
%% --main loop: i = loop index. it # steps
%% i2 points to current column in P, AP. Cycling storage used 
i2= 1;
i = 1;
fprintf('   Iteration    fval       grad_norm\n');
for it =1:itmax 
    history = [history sol];
    alph = AP'*r;
%     disp(AP)
    sol = sol + P * alph;
    
    [fun_val, r]  = fun(sol);
    rho = norm(r);
    
    FVAL = [FVAL; fun_val];
    fprintf('   %5d    %10.3e    %10.3e\n', it, fun_val, rho);
    Ar = imag(FF(sol-ep*r*imagi)/ep);
    disp(FF(sol))
    %% || Ar || / ep  ~ || FF(u+ep*r)- FF(u) || 
    %%--------------------orthonormnalize  Ap's
    p  = r;
    if (i <= lb), k = 0; else, k=i2; end
    while(1) 
        %%---------- define next column - circular storage to avoid copying
        if (k  ==  lb), k=0; end
        k = k+1;
        tau = dot(Ar,AP(:,k));
        p = p-tau*P(:,k);
       
        Ar = imag(FF(sol-ep*r*imagi)/ep);
        %%---------- update u (last column of current Hess. matrix)
        if (k == i2), break; end
    end
    t = norm(Ar);
    %%-------------------- Now  Ar==Ap. If   Ap == 0 can't advance         
    if (t == 0.0)
        return; 
    end
    %%-------------------- we restart every `restart' iterations
    if (mod(it,restart) == 0) 
        i2 = 0;
        i  = 0;
        P  = zeros(n,lb);
        AP = zeros(n,lb);
        %%--------------------initial residual vector and norm 
        r  = FF(sol);
        Ar = imag(FF(sol-ep*r*imagi)/ep);
        t  = norm(Ar);
        p  = r;
    end
    %%-------------------- truncate subspace  
    if (i2  == lb), i2=0; end
    i2=i2+1;
    i = i+1;
    t = 1.0 / t;
    AP(:,i2) = t*Ar;
    P(:,i2) = p*t;
end
    function grad = FF(x) % gets the gradient of anonymous function fun
        [~,grad] = fun(x); 
    end
end