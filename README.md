# tensormesh_assignment 

## part 2

question 1 - What happens when both requests arrive at the same time in each version? Give a short cycle table.

          1)in fixed priority arbiter - only the data of the highest priority requester gets sent to out_data.
          2)in round robin arbiter - the arbiter remembers which requester was granted last and depending on that it grants to one of the requesters
            (if A was granted last then B is granted now and vice versa)

question 2 - What is the problem with always giving A priority?
          B never gets granted (starvation of B)
          - when both requests are high for 20 cycles, in fixed arbiter B gets 0 grants and in round robin arbiter B gets 10 grants.

question 3 -version 2 remembers which module was granted last and gives priority to the module which was not granted last. Therefore, if both A and B continuously request               access, they get alternate grants. The longest B can wait is two cycles.
