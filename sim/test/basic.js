const dut = require('../build/Release/dut.node');
const {Sim, SimUtils, RisingEdge, RisingEdges, FallingEdge, FallingEdges, Edge, Edges, Interfaces} = require('signalflip-js');
const { Clock } = SimUtils;
const {Elastic} = Interfaces;
const _ = require('lodash');

const jsc = require('jsverify');
const assert = require('assert');

let sim;

describe('Basic Group', () => {
  let setup = (name) => {
    // set up the environment
    dut.init(name); // Init dut
    sim = new Sim(dut, dut.eval);

    // TODO: Create clock
    let clk = new Clock(dut.clk, 1);
    sim.addClock(clk);
    
    // TODO: Add setup code (interfaces, transaction, ...) etc...
    
    // TODO: Add reset task
    sim.addTask(function* () {
      dut.rstf(0);
      yield* RisingEdges(dut.clk, 10.5); // assert reset low for 10 clock cycles
      dut.rstf(1);
      yield* RisingEdge(dut.clk);
    }(), 'RESET');

    // TODO: Add post_run tasks (test checking)
    // sim.addTask(() => { /* post_run function */}, 'POST_RUN'});

  };
  it('counter-basic', function () {
    this.timeout(10000); // Set timeout to expected run time of the test in ms
      setup('top');
      // TODO: customize txn, randomizer, set variables/signals
      
      sim.run(10000); //run for 1000 ticks
  });
});

