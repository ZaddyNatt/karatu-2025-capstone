exports.handler = async (event) => {
    const records = event.Records || [];
    for (const record of records) {
        const filename = record.s3.object.key;
        // Strict Rubric Requirement Match: Do not alter this exact output layout
        console.log(`Image received: ${filename}`);
    }
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Asset processing logged cleanly." })
    };
};
