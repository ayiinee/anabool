from fastapi import UploadFile


async def preprocess_image(file: UploadFile):
    image_bytes = await file.read()

    return {
        "filename": file.filename,
        "content_type": file.content_type,
        "size_bytes": len(image_bytes),
    }