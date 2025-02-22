`ifndef CLKGEN_SV
`define CLKGEN_SV

module clkgen #(
  parameter real FREQ_MHZ = 100.0,
  parameter real JITTER_PERCENT = 0.0
)(
  output reg clk;
);
  real half_period_ns;
  real jitter_ns;

  initial begin
    clk = 0;
    half_period_ns = (1000.0 / FREQ_MHZ) / 2.0;
    jitter_ns = half_period_ns * (JITTER_PERCENT / 100.0);
    forever begin
      #(half_period_ns + $urandom_range(-jitter_ns, jitter_ns));
      clk = ~clk;
    end
  end
endmodule

`endif
