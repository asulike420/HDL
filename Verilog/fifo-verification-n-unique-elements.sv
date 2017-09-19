//
// I have a synchronous FIFO. The depth of the FIFO is 32.
// Everytime the FIFO has 7 or any "n" unique elements inside it,
// "unique" signal goes HIGH. How do I test the "unique" signal going high
// in SystemVerilog or UVM? How would my scoreboard look like?

import uvm_pkg::*; `include "uvm_macros.svh"
module top;
	bit clk, pop, push;
	int data=8, q1_size, aa_num, just_popped, aa_uniques_size;
	int aa[int]; // associative array
	int q1[$];  // queue, emulating the fifo
	int num_unique=0;
	int aa_uniques[$]; // for use with the unique method
	// NEW solution
	/* unique() returns all elements with unique values or whose expression evaluates to a unique value.
The queue returned contains one and only one entry for each of the values found in the array. The
ordering of the returned elements is unrelated to the ordering of the original array
int IA[int], qi[$];
string SA[10], qs[$];
// Find all unique string elements
qs = SA.unique;
// Find all unique strings in lowercase
qs = SA.unique( s ) with ( s.tolower );
*/
	always @(posedge clk)  begin
		automatic int temp_pop;
		if(push) begin : push1  // if(push && !pop) begin : push_no_pop
			if(!aa.exists(data)) begin : is_unique
				aa[data]=1;  // flag data into associative array
				num_unique =  num_unique+1'b1; // incremnet number of uniques
				q1.push_front(data); // maintain the queue
			end  : is_unique
		    else  begin : is_not_unique // but is in the queue
			   aa[data]+=1'b1;  // keep track of count
			   // num_unique <=  num_unique+1'b1; // incremnet number of uniques
			   q1.push_front(data); // maintain the queue
		    end  : is_not_unique
		end : push1
		if(pop && q1.size != 0) begin : pop_q  // if(pop && !push && q1.size != 0)
			temp_pop=q1.pop_back(); // maintain the queue
			aa[temp_pop]-=1'b1;  // keep track of count
			just_popped <= temp_pop;
			if(aa[temp_pop]==0) begin : flushed
			  num_unique = num_unique - 1'b1; // decrement uniques
			  aa.delete(temp_pop); // delete the associative array entry
			end  : flushed
		end : pop_q
		a_unique: assert(num_unique <= 7);
		// aa_uniques.delete; // clear the temp associative array
		aa_uniques=q1.unique;

		// debug
		q1_size=q1.size; // for debug
		aa_num=aa.num; // number of unique entries
		aa_uniques_size = aa_uniques.size;
		a2_unique: assert(aa_uniques.size <=7);
	end

	initial forever #10 clk=!clk;

	initial begin
		repeat(5) push <= 1'b1;
		repeat(200) begin
			@(posedge clk);   #2;
			if (!randomize(push, pop, data)  with
					{ push dist {1'b1:=1, 1'b0:=2};
					  pop  dist {1'b1:=1, 1'b0:=8};
					  data dist {[1:12]:=1, [0:0]:=3};
					}) `uvm_error("MYERR", "This is a randomize error")
		end
		$stop;
	end
endmodule
 
