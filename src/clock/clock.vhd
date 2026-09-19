


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is

	port (
		clk		: in std_logic;
		reset		: in std_logic;
		enable	: in std_logic;
		r_out : out std_logic_vector (3 downto 0)
	);

end entity lfsr;


architecture behavioral of lfsr is

	signal c_bit : std_logic;
	signal r_reg : std_logic_vector (3 downto 0) := "0001";

begin

	-- determine the c bit
	c_bit <= r_reg(0) xor r_reg(1) xor r_reg(2) xor r_reg(3);
	
	process(clk, reset)
	begin
	
		if reset = '1' then 
			r_reg <= "0001";
		elsif rising_edge(clk) then
			if enable = '1' then
				r_reg <= r_reg(2 downto 0) & c_bit;	
			end if;
		end if;
	
	end process;

    r_out <= r_reg;

end architecture behavioral;