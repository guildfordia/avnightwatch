// toto

function extract() {
    try {
        var d = new Dict("data");
        //post("✅ Loaded dict.\n");

        var emoLabel = d.get("data::emotion::output");
        var sentLabel = d.get("data::sentiment::output");

        //post("Emotion label:", emoLabel, "\n");
        //post("Sentiment label:", sentLabel, "\n");

        var emoList = d.get("data::emotion::probas");
        var sentList = d.get("data::sentiment::probas");

        var emoScore = 0;
        var sentScore = 0;
        var pos = 0;
        var neg = 0;

        // Loop over emotion list
        for (var i = 0; i < emoList.length; i++) {
            var item = emoList[i];
            var label = item.get("label");
            var score = item.get("score");

            //post("🔍 Emotion item", i, ": ", label, score, "\n");

            if (label === emoLabel) {
                emoScore = score;
                //post("✅ Matched emotion score:", emoScore, "\n");
            }
        }

        // Loop over sentiment list
        for (var i = 0; i < sentList.length; i++) {
            var item = sentList[i];
            var label = item.get("label");
            var score = item.get("score");

            //post("🔍 Sentiment item", i, ": ", label, score, "\n");

            if (label === sentLabel) {
                sentScore = score;
                //post("✅ Matched sentiment score:", sentScore, "\n");
            }
            if (label === "POS") pos = score;
            if (label === "NEG") neg = score;
        }

        var polarity = (pos + neg > 0) ? (pos - neg) / (pos + neg) : 0;

        //post("✅ OUT:", emoLabel, emoScore, sentLabel, sentScore, polarity, "\n");
        outlet(0, emoLabel, emoScore, sentLabel, sentScore, polarity);

    } catch (err) {
        post("❌ JS Error: " + err.message + "\n");
    }
}
