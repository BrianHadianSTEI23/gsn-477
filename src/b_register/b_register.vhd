library ieee;
use ieee.std_logic_1164.all;

entity b_register is
    port (
        clk      : in  std_logic;                    -- System clock
        rst      : in  std_logic;                    -- Global reset (active high)
        load_b   : in  std_logic;                    -- Load enable from control matrix
        data_in  : in  std_logic_vector(3 downto 0); -- Input from Data Bus
        b_out    : out std_logic_vector(3 downto 0)  -- Dedicated 4-bit output to ALU
    );
end entity b_register;

architecture behavioral of b_register is
    signal reg_val : std_logic_vector(3 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            reg_val <= (others => '0');
        elsif rising_edge(clk) then
            if load_b = '1' then
                reg_val <= data_in;
            end if;
        end if;
    end process;

    b_out <= reg_val;

end architecture behavioral;