library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    port (
        clk    : in  std_logic;                    -- System clock
        rst    : in  std_logic;                    -- Global reset (active high)
        inc    : in  std_logic;                    -- Increment enable from control matrix
        pc_out : out std_logic_vector(3 downto 0)  -- 4-bit memory address output
    );
end entity program_counter;

architecture behavioral of program_counter is
    signal count : unsigned(3 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            count <= (others => '0');
        elsif rising_edge(clk) then
            if inc = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;

    pc_out <= std_logic_vector(count);

end architecture behavioral;