%{
Simple Genetic Algorithm (GA) Optimization from Scratch
Author: Ziam Ghaznavi
Data:   05/2019

This program using a single-object constrained GA to solve a continuous 
objective function, then plots the results.
%}

%%
clc; close all; clear all

% The objective function we want to maximize
obj_func = @(x) sin(x) + 0.05*x^2 + 1; 
lower_bound = -7 ;
upper_bound = 7;
pop_size = 10;
crossover_prob = 0.7;
mutation_prob = 0.06;
elitism = 2;
num_encode_bits = 6;
num_generations = 5; 
%Encoding my variables
s = (upper_bound - lower_bound)/(2^num_encode_bits - 1);    %interval step size
decode = @(y) lower_bound + s*y;   %function to decode binary variable values

%Creation of random initial population
for i = 1:pop_size
    gen(1).design(i).xid = randi([0, 2^num_encode_bits-1], 1);   %generate a random number between 0-63 ten times
    gen(1).design(i).xib = dec2bin(gen(1).design(i).xid,num_encode_bits); %binary representation of encoded design variable
    gen(1).design(i).xi = decode(gen(1).design(i).xid); %decimal rep of decoded design variable
    gen(1).design(i).f = obj_func(gen(1).design(i).xi);    %fitness function value of design
end
%%
% Arranging designs in first generation in ascending order according to
% fitness
T = struct2table(gen(1).design); % convert the struct array to a table
sortedT = sortrows(T, 'f'); % sort the table by 'f' in ascending order
sortedS = table2struct(sortedT); % change it back to struct array 
gen(1).design = sortedS; % sorted fitness values of initial population

%% Plot inital population
figure(1);
fplot(obj_func, [-7,7]);
hold on;
for i = 1:pop_size
    x(i) = gen(1).design(i).xi;
    y(i) = gen(1).design(i).f;
    scatter(x, y);
end

%% Main Loop
for g = 2:num_generations
    % Automatically carrying over elitist solutions
    for i = 1:elitism
        gen(g).design(i) = gen(g-1).design(pop_size - (i - 1)); %picking the best E designs from previous generation
    end
    
    % Creation of mating pool
    total = 0;  
    %summation of fitness values from previous generation
    for i = 1:pop_size
       total = total + (gen(g-1).design(i).f - gen(g-1).design(1).f);
    end

    % Cross over 
    index = 1;
    while size(gen(g).design,2) < pop_size
        %selection parent pair for cross over
        for i = 1:2 
            flag = 0;
            j = 2;
            r = rand;
            sum = 0;
            while flag == 0
                sum = sum + (gen(g-1).design(j).f - gen(g-1).design(1).f);
                if sum/total >= r
                    flag = 1;
                    candidate(i) = j;   %array of index values from previous generation i.e. parents
                else
                    j = j+1;
                end
            end
        end
        %generate random number to determine cross over of parent pair
        r = rand;   
        %if r is less than Pc, proceed to cross over
        if r <= crossover_prob  
            %generate random number for cross over point
            r = randi([0, num_encode_bits],1);   
            gen(g).design(elitism+index).xib = [gen(g-1).design(candidate(1)).xib(1:r) gen(g-1).design(candidate(2)).xib(r+1:num_encode_bits)];
            gen(g).design(elitism+index+1).xib = [gen(g-1).design(candidate(2)).xib(1:r) gen(g-1).design(candidate(1)).xib(r+1:num_encode_bits)];
        else
            %clone parents to next generation
            gen(g).design(elitism+index).xib = gen(g-1).design(candidate(1)).xib;
            gen(g).design(elitism+index+1).xib = gen(g-1).design(candidate(2)).xib;
        end
        index = index + 2;

        if size(gen(g).design,2) > pop_size
            gen(g).design(pop_size+1) = []; %delete extra element from structure array
        end
    end
    
    % Mutation
    for i = 1:pop_size %for each design in new generation 
        r = rand;  %generate random number
        if r <= mutation_prob  %if random number is below Pm
            for j = 1:num_encode_bits     %go through each bit of the current design
                r = rand;  %generate another random number
                if r<= mutation_prob   %if this random number is less than Pm again
                    if gen(g).design(i).xib(j) == '0'     %flip the current bit
                        gen(g).design(i).xib(j) = '1';
                    else
                        gen(g).design(i).xib(j) = '0';
                    end
                end
            end
        end
    end
    
    % Evaluation of new generation
    for i = 1:pop_size
        gen(g).design(i).xid = bin2dec(gen(g).design(i).xib);   %convert to decimal value of encoded variable
        gen(g).design(i).xi = decode(gen(g).design(i).xid); %decimal rep of decoded design variable
        gen(g).design(i).f = obj_func(gen(g).design(i).xi);    %fitness function value of design
    end
    
    % Arrange generation in ascending value
    T = struct2table(gen(g).design); % convert the struct array to a table
    sortedT = sortrows(T, 'f'); % sort the table by 'f' in ascending order
    sortedS = table2struct(sortedT); % change it back to struct array 
    gen(g).design = sortedS; % sorted fitness values of initial population
    
    % Plotting results (could have done this better)
    x = [];
    y = [];
    for i = 1:pop_size
        x(i) = gen(g).design(i).xi;
        y(i) = gen(g).design(i).f;
        scatter(x, y);
    end
    legend('Objective Func', 'Gen #1', 'Gen #2', 'Gen #3', 'Gen #4', 'Gen #5');
end

% Display optima identified by the GA
x_optima = gen(num_generations).design(pop_size)