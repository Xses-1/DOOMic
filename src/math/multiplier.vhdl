
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
generic
(
	n_bits : integer := 24;
	f_bits : integer := 8
);
port 
(
	a : in  std_logic_vector(n_bits - 1 downto 0);
	b : in  std_logic_vector(n_bits - 1 downto 0);
	r : out std_logic_vector(n_bits - 1 downto 0)
);
end entity ; -- multiplier

architecture arch of multiplier is
	signal tmp : signed((n_bits * 2) - 1 downto 0);
begin
	tmp <= signed(a) * signed(b);
	r   <= std_logic_vector(resize(tmp, n_bits));
end architecture ; -- arch
