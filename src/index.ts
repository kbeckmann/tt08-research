import tt_um_top_v from './tt_um_top.v?raw';
import hvsync_gen_v from './hvsync_gen.v?raw';
import pdm_v from './pdm.v?raw';

export const synth = {
  name: 'Synth',
  author: 'kbeckmann',
  topModule: 'tt_um_top',
  sources: {
    'tt_um_top.v': tt_um_top_v,
    'pdm.v': pdm_v,
    'hvsync_gen_v': hvsync_gen_v,
  },
};
