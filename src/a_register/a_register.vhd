library ieee;
use ieee.std_logic_1164.all;

entity a_register is
    port (
        clk      : in    std_logic;                    -- System clock
        rst      : in    std_logic;                    -- Global reset (active high)
        load_a   : in    std_logic;                    -- Load enable from control matrix
        en_a_bus : in    std_logic;                    -- Bus driver enable (tri-state)
        data_bus : inout std_logic_vector(3 downto 0); -- Shared 4-bit Data Bus
        a_out    : out   std_logic_vector(3 downto 0)  -- Dedicated 4-bit output to ALU
    );
end entity a_register;

architecture behavioral of a_register is
    signal reg_val : std_logic_vector(3 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            reg_val <= (others => '0');
        elsif rising_edge(clk) then
            if load_a = '1' then
                reg_val <= data_bus;
            end if;
        end if;
    end process;

    -- Tri-state output to Data Bus
    data_bus <= reg_val when en_a_bus = '1' else (others => 'Z');

    -- Continuous output to ALU
    a_out <= reg_val;

end architecture behavioral;