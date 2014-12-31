library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY butterfly_1 is
	PORT (		
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);

		r : out std_logic_vector(31 downto 0)
	);
END butterfly_1;

architecture rtl of butterfly_1 is

begin
	r <= std_logic_vector(shift_right((signed(a)-signed(b)),1));
end rtl;
