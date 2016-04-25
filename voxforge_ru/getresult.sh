#!/bin/bash

grep WER exp/tri1/decode/wer_* | utils/best_wer.sh

grep WER exp/tri2a/decode/wer_* | utils/best_wer.sh
grep WER exp/tri2b/decode/wer_* | utils/best_wer.sh

grep WER exp/tri2b_mmi/decode_it3/wer_* | utils/best_wer.sh
grep WER exp/tri2b_mmi/decode_it4/wer_* | utils/best_wer.sh

grep WER exp/tri2b_mmi_b0.05/decode_it3/wer_* | utils/best_wer.sh
grep WER exp/tri2b_mmi_b0.05/decode_it4/wer_* | utils/best_wer.sh

grep WER exp/tri2b_mpe/decode_it3/wer_* | utils/best_wer.sh
grep WER exp/tri2b_mpe/decode_it4/wer_* | utils/best_wer.sh

grep WER exp/tri3b/decode/wer_* | utils/best_wer.sh
grep WER exp/tri3b_mmi/decode2/wer_* | utils/best_wer.sh
