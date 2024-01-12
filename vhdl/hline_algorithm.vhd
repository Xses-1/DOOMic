library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity algorithm is
    port (
	clk		: in std_logic;
	reset		: in std_logic;
	sel   		: in std_logic;
	enable		: in std_logic;

	start_pos_1 	: in std_logic_vector(8 downto 0);
	start_pos_2	: in std_logic_vector(8 downto 0);
        right_cond_in	: in std_logic_vector(8 downto 0);

        dxy1_in		: in std_logic_vector(8 downto 0);
        dxy2_in		: in std_logic_vector(8 downto 0);

	address		: out std_logic_vector(15 downto 0);
	ready		: out std_logic    );
end entity algorithm;

architecture behavioural of algorithm is

	type loop_states is (		reset_state,		-- sets everything to 0
					populate,		-- initializes start values
					for_loop,		-- checks if 'loop' is done or should continue
					prepare_draw,		-- sets with 'sel' if 'start_pos_1' is x or y and 'start_pos_2' is x or y
								-- and appropriately assigns them to temp x, y signals.
					draw_1_mulp,		-- mulp_y <= 320 * y 
					draw_1_add,		-- address_temp <= mulp_y + x
					address_1_out, 		-- address out (320 * y + x)

					mirror, 		-- 199 - y 
					draw_2_mulp,		-- 320 * mirror_y
					draw_2_add,		-- + x
					address_2_out, 		-- address out (320 * y_mirror + x)

					e_calc, 		-- e + dy (sel = '1') or e + dx (sel = '0')
					e_shift_compare_temp,	-- temp. shifts e to left (e * 2)
					e_compare, 		-- compares shifted value to dxy2 and determined next new state
					e_calc1, 		-- e - dx (sel = '1') or e - dy (sel = '0')

					count_increase, 	-- x+1 (sel = '1') or y + 1 (sel = '0')
					sec_count_increase, 	-- y+1 (sel = '1') or x+1 (sel = '0')
					done);
	
	signal state, next_state: loop_states;

-- 'signals' (memory) used for counters.
signal position, new_position: unsigned(8 downto 0);
signal sec_position, new_sec_position: unsigned(8 downto 0);
signal e_count, new_e_count: signed(15 downto 0);


-- 'signals' to (temporary) store values (memory elements)
signal address_temp: std_logic_vector(15 downto 0);
signal draw_x_sig: unsigned(8 downto 0);
signal draw_y_sig: unsigned(7 downto 0);
signal mirror_y: unsigned(7 downto 0);
signal mulp_y, mulp_mirror_y: std_logic_vector(16 downto 0);
signal dxy1, dxy2, right_cond: std_logic_vector(8 downto 0);


-- signals used to connect to components.
signal shift_in_sign, shift_out_sign, shift_out_temp: std_logic_vector(15 downto 0);
signal add_1_sig, add_2_sig, sub_sig, result_adder_sig: std_logic_vector(15 downto 0);

component bitshift_left is
	port(
		input  : in  std_logic_vector(15 downto 0);	
		output : out std_logic_vector(15 downto 0);
		flag   : out std_logic
	);
end component;

component plus_minus is
	port(
		add_1	: in std_logic_vector(15 downto 0);
		add_2	: in std_logic_vector(15 downto 0);
		sub	: in std_logic_vector(15 downto 0);
		result	: out std_logic_vector(15 downto 0));
end component;


begin

bitshift: bitshift_left
port map(
	input 	=> shift_in_sign,
	output 	=> shift_out_sign,
	flag 	=> open);

addsub: plus_minus
port map(
	add_1	=> add_1_sig,
	add_2	=> add_2_sig,
	sub  	=> sub_sig,
	result 	=> result_adder_sig);


	process (clk)
	begin	
		if (rising_edge (clk)) then
			if (reset = '1') then
				state 		<= reset_state;
				position 	<= (others => '0');
				sec_position 	<= (others => '0');
				e_count 	<= (others => '0');

			else 
				state 		<= next_state;
				position 	<= new_position;
				sec_position 	<= new_sec_position;
				e_count 	<= new_e_count;

			end if;
		end if;
	end process;

	process (state, enable, e_count, position, sec_position, result_adder_sig, draw_x_sig)
	begin
		case state is
			when reset_state => 
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');

				dxy1		<= (others => '0');
				dxy2		<= (others => '0');
				right_cond	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '0';

				new_position 	<= (others => '0');
				new_sec_position<= (others => '0');
				new_e_count 	<= (others => '0');

				if (enable = '1') then
					next_state <= populate;
				else
					next_state <= reset_state;
				end if;

			when populate => 		-- initializes start values for the 'loop'
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');

				dxy1		<= dxy1_in;
				dxy2		<= dxy2_in;
				right_cond	<= right_cond_in;	


				address 	<= (others => '0');
				ready 		<= '0';

				new_position 	<= unsigned(start_pos_1);
				new_sec_position<= unsigned(start_pos_2);
				new_e_count 	<= (others => '0');

				next_state 	<= for_loop;
			
		
			when for_loop =>		-- checks if 'loop' is done or should continue
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '1';

				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				if (unsigned(position) < unsigned(right_cond)) then
					next_state <= prepare_draw;

				else
					next_state <= done;
				end if;


			when done =>		-- The done state is when the end of a wall is reached NOT end of frame.
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');

				if (((unsigned(position)+1) mod 320) = 0) then 
					address 	<= "1111111111111110"; 
					ready 		<= '1';
				else 
					address		<= (others => '0');
					ready		<= '0';
				end if;

				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				next_state 	<= reset_state;

			when prepare_draw =>		-- sets with 'sel' if 'start_pos_1' is x or y and 'start_pos_2' is x or y
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				if (sel = '1') then
					draw_x_sig <= position;
					draw_y_sig <= sec_position(7 downto 0);
				else
					draw_x_sig <= sec_position;
					draw_y_sig <= position(7 downto 0);
				end if;
				address_temp	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '1';

				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				next_state 	<= draw_1_mulp;

			when draw_1_mulp =>		-- for address = 320*y+x, first 320*y
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= std_logic_vector((draw_y_sig & "00000") * "1010"); --320*y;
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= draw_x_sig;
				draw_y_sig	<= draw_y_sig;
				address_temp	<= (others => '0');


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				address 	<= (others => '0');
				ready 		<= '1';

				next_state 	<= draw_1_add;


			when draw_1_add => 		-- + x
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= mulp_y(15 downto 0);
				add_2_sig 	<= std_logic_vector("0000000"& draw_x_sig);
				sub_sig 	<= (others => '0');


				mulp_y 		<= mulp_y;
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= draw_x_sig;
				draw_y_sig	<= draw_y_sig;
				address_temp	<= result_adder_sig; 	


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				address 	<= (others => '0');			
				ready 		<= '1';

				next_state 	<= address_1_out;

			when address_1_out => 		-- address <= 320*y+x
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= draw_x_sig;
				draw_y_sig	<= draw_y_sig;
				address_temp	<= address_temp;

				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				address 	<= address_temp; -- final output is 320*draw_y_sig + draw_x_sig
				ready 		<= '1';

				next_state 	<= mirror;

			when mirror =>			-- y gets mirrored, this to draw the second line
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= "0000000011000111";
				add_2_sig 	<= (others=> '0');
				sub_sig 	<= ("00000000" & std_logic_vector(draw_y_sig));


				mulp_y 		<= (others => '0');
				mirror_y 	<= unsigned(result_adder_sig(7 downto 0));
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= draw_x_sig;
				draw_y_sig	<= draw_y_sig;
				address_temp	<= (others => '0');


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				address 	<= (others => '0');
				ready 		<= '1';

				next_state 	<= draw_2_mulp;


			when draw_2_mulp =>		-- 320*mirror_y (address = 320*y_mirror+x)
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= mirror_y;
				mulp_mirror_y 	<= std_logic_vector((mirror_y & "00000") * "1010");
				draw_x_sig	<= draw_x_sig;
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				address 	<= (others => '0');
				ready 		<= '1';

				next_state 	<= draw_2_add;

			when draw_2_add =>		-- + x
				shift_in_sign 	<= (others => '0');
				add_1_sig	<= mulp_mirror_y(15 downto 0);
				add_2_sig 	<= std_logic_vector("0000000"& draw_x_sig);
				sub_sig 	<= (others=> '0');


				mulp_y 		<= (others => '0');
				mirror_y	<= (others => '0');
				mulp_mirror_y 	<= mulp_mirror_y;
				draw_x_sig	<= draw_x_sig;
				draw_y_sig	<= (others => '0');
				address_temp	<= result_adder_sig; -- 320mirror_y+x_position;


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;


				address 	<= (others => '0');
				ready 		<= '1';

				next_state 	<= address_2_out;

			when address_2_out =>		-- address out (320 * mirror_y + x)
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= address_temp;


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				address 	<= address_temp;
				ready 		<= '1';

				next_state 	<= e_calc;


			when e_calc =>			-- e + dy or e + dy depending on 'sel' signal
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= std_logic_vector(e_count);
				add_2_sig 	<= std_logic_vector("0000000"& dxy1);
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= signed(result_adder_sig);	

				address 	<= (others => '0');
				ready 		<= '1';

				next_state 	<= e_shift_compare_temp;


			when e_shift_compare_temp =>		-- e**2
				shift_in_sign 	<= std_logic_vector(e_count);
				shift_out_temp 	<= shift_out_sign;

				add_1_sig	<= (others => '0');
				add_2_sig	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				address 	<= (others => '0');
				ready 		<= '1';

				next_state 	<= e_compare;


			when e_compare =>		-- (e**2) > dxy2 
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '1';

				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				
				if (signed(shift_out_temp) > signed("0000000" & dxy2)) then
					next_state <= e_calc1;
				else
					next_state <= count_increase;
				end if;


			when e_calc1 =>			-- e - dx (sel = '1') or e - dy
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= std_logic_vector(e_count);
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (std_logic_vector("0000000"& dxy2));


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '1';

				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= signed(result_adder_sig);

				next_state 	<= sec_count_increase;


			when sec_count_increase => 	-- x + 1 or y + 1 
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '1';

				new_position 	<= position;
				new_sec_position<= sec_position+1;
				new_e_count 	<= e_count;

				next_state 	<= count_increase;


			when count_increase =>		-- x + 1 or y + 1, depending on which axis the algorithm iterates
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '1';

				new_position 	<= position + 1;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				next_state 	<= for_loop;

			when others =>
				shift_in_sign 	<= (others => '0');
				add_1_sig 	<= (others => '0');
				add_2_sig 	<= (others => '0');
				sub_sig 	<= (others => '0');


				mulp_y 		<= (others => '0');
				mirror_y 	<= (others => '0');
				mulp_mirror_y 	<= (others => '0');
				draw_x_sig	<= (others => '0');
				draw_y_sig	<= (others => '0');
				address_temp	<= (others => '0');


				address 	<= (others => '0');
				ready 		<= '0';

				new_position 	<= position;
				new_sec_position<= sec_position;
				new_e_count 	<= e_count;

				next_state 	<= reset_state;
				
		end case;
	end process;	
end architecture behavioural;
