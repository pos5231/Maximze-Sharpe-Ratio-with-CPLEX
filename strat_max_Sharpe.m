function  [w_maxsharpe] = strat_max_Sharpe(mu, Q, cur_prices)

n = 100;
addpath('/home/prash/CPLEX/cplex/matlab/x86-64_linux');

%Given risk-free rate
r_rf = 0.045;

%% Checking if there is a non negative Sharpe Ratio

var = diag(Q);
b = int8(all(mu < 0));

if b == 1
    
    x_optimal = x_init;
    cash_optimal = cash_init;
    
else
    
    Q=[Q;zeros(1,n)];
    Q=[Q zeros(n+1,1)];
    %% CPLEX Solution
    % Initialize the CPLEX object
    cplex3 = Cplex('max_Sharpe');
    cplex3.Model.sense = 'minimize';
    
    % Optimization problem data
    lb = -inf(n+1,1);
    ub = inf*ones(n+1,1);
    %
    A = [[(  mu- r_rf/252) 0];[ones(1,n) -1]; [eye(n,n) -1*ones(n,1)]];
    y = ones(n+1,1);
    lhs = [1; 0; -inf*ones(n,1)];
    rhs = [1; 0; zeros(n,1)];
    
    y = ones(n+1,1);
    
    % Add objective function and bounds on variables to CPLEX model
    cplex3.addCols(zeros(n+1,1), [], lb, ub);
    % Add constraints to CPLEX model
    cplex3.addRows(lhs, A, rhs);
    
    % Add quadratic part of objective function to CPLEX model
    cplex3.Model.Q = 2*Q;
    % Set CPLEX parameters
    cplex3.Param.qpmethod.Cur = 6;
    cplex3.Param.barrier.crossover.Cur = 1;% Concurrent algorithm
    % Optimize the problem
    cplex3.DisplayFunc = [];
    cplex3.solve();
 
    y = cplex3.Solution.x(1:n);
    k = cplex3.Solution.x(n+1);
    
    w_maxsharpe = y/k;
    
  end

