export function sendResponse({ res, status = true, code = status ? 200 : 500, message, data }) {

    const body = { status };

    if (message !== undefined) {
        body.message = message;
    }

    if (data !== undefined) {
        body.data = data;
    }

    return res.status(code).json(body);

}
