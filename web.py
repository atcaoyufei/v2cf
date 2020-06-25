import os

from flask import Flask, jsonify

app = Flask(__name__, static_url_path='')


@app.route('/')
def root():
    return jsonify(os.environ)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
