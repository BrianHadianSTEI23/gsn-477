library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    port (
        clk        : in    std_logic;                    -- System clock
        rst        : in    std_logic;                    -- Global reset (loads initial program/data)
        addr       : in    std_logic_vector(3 downto 0); -- 4-bit memory address input (0 to 15)
        write_en   : in    std_logic;                    -- Memory write enable
        en_mem_bus : in    std_logic;                    -- Output enable to Data Bus (tri-state)
        data_bus   : inout std_logic_vector(3 downto 0); -- Shared 4-bit Data Bus
        mem_out    : out   std_logic_vector(3 downto 0)  -- Direct read port output
    );
end entity memory;

architecture behavioral of memory is

    -- 16-word x 4-bit memory array type (covering full 4-bit address space)
    type ram_type is array (0 to 15) of std_logic_vector(3 downto 0);

    -- Default preloaded program / test pattern (Addresses 0 to 9 map to GSN477 Bytes 1-10)
    constant INIT_RAM : ram_type := (
        0 => "0001", -- Address 0 (Byte 1)
        1 => "0010", -- Address 1 (Byte 2)
        2 => "0100", -- Address 2 (Byte 3)
        3 => "1000", -- Address 3 (Byte 4)
        4 => "0011", -- Address 4 (Byte 5)
        5 => "0110", -- Address 5 (Byte 6)
        6 => "1100", -- Address 6 (Byte 7)
        7 => "1001", -- Address 7 (Byte 8)
        8 => "1111", -- Address 8 (Byte 9)
        9 => "0101", -- Address 9 (Byte 10)
        others => "0000"
    );

    signal ram : ram_type := INIT_RAM;
    signal current_data : std_logic_vector(3 downto 0);

begin

    -- Synchronous Write & Reset Process
    process(clk, rst)
        variable idx : integer range 0 to 15;
    begin
        if rst = '1' then
            ram <= INIT_RAM;
        elsif rising_edge(clk) then
            idx := to_integer(unsigned(addr));
            if write_en = '1' then
                ram(idx) <= data_bus;
            end if;
        end if;
    end process;

    -- Asynchronous Read Output
    current_data <= ram(to_integer(unsigned(addr)));
    mem_out      <= current_data;

    -- Tri-State Driver to Data Bus
    data_bus <= current_data when en_mem_bus = '1' else (others => 'Z');

end architecture behavioral;