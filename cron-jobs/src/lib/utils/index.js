'use strict';

class Utils {

    /**
     * Wraps async/await
     */
    promisify (_inner) {
        return new Promise((resolve, reject) => {
            _inner((err, res) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(res);
                }
            });
        });
    }

}

module.exports = new Utils();
