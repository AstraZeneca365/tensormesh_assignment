# tensormesh_assignment 

## part 2

question 1 - What happens when both requests arrive at the same time in each version? Give a short cycle table.

          1)in fixed priority arbiter - only the data of the highest priority requester gets sent to out_data.
          2)in round robin arbiter - the arbiter remembers which requester was granted last and depending on that it grants to one of the requesters
            (if A was granted last then B is granted now and vice versa)
          | Cycle | Fixed Priority Grant | Round-Robin Grant |
                  |---:|---|---|
                  | 1 | A | A |
                  | 2 | A | B |
                  | 3 | A | A |
                  | 4 | A | B |
                  | 5 | A | A |
                  | 6 | A | B |
