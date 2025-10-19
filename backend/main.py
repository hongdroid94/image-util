from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from rembg import remove
from PIL import Image
import io
import time

app = FastAPI(title="Image Util API", version="1.0.0")

# CORS 설정 - Netlify 프론트엔드 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "https://image-util.netlify.app",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    allow_origin_regex=r"https://.*\.netlify\.app",
)


@app.get("/")
async def root():
    return {
        "message": "Image Util API",
        "version": "1.0.0",
        "endpoints": {
            "remove_background": "/api/remove-background",
            "upscale": "/api/upscale",
            "health": "/health",
        },
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": time.time()}


@app.post("/api/remove-background")
async def remove_background(file: UploadFile = File(...)):
    """
    이미지 배경 제거 API
    
    - **file**: 업로드할 이미지 파일 (JPG, PNG, WebP)
    - 반환: 배경이 제거된 PNG 이미지
    """
    try:
        # 파일 타입 검증
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")
        
        # 파일 크기 제한 (10MB)
        contents = await file.read()
        if len(contents) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="파일 크기는 10MB 이하여야 합니다.")
        
        # 이미지 로드
        input_image = Image.open(io.BytesIO(contents))
        
        # 배경 제거
        output_image = remove(input_image)
        
        # PNG로 변환
        img_byte_arr = io.BytesIO()
        output_image.save(img_byte_arr, format='PNG')
        img_byte_arr.seek(0)
        
        return StreamingResponse(
            img_byte_arr,
            media_type="image/png",
            headers={
                "Content-Disposition": f"attachment; filename=removed_{file.filename}.png"
            },
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"이미지 처리 중 오류 발생: {str(e)}")


@app.post("/api/upscale")
async def upscale_image(file: UploadFile = File(...), scale: int = 2):
    """
    이미지 업스케일링 API
    
    - **file**: 업로드할 이미지 파일 (JPG, PNG, WebP)
    - **scale**: 확대 배율 (2 or 4, 기본값: 2)
    - 반환: 업스케일된 PNG 이미지
    """
    try:
        # 배율 검증
        if scale not in [2, 4]:
            raise HTTPException(status_code=400, detail="배율은 2 또는 4만 가능합니다.")
        
        # 파일 타입 검증
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")
        
        # 파일 크기 제한 (10MB)
        contents = await file.read()
        if len(contents) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="파일 크기는 10MB 이하여야 합니다.")
        
        # 이미지 로드
        input_image = Image.open(io.BytesIO(contents))
        
        # 원본 크기
        original_width, original_height = input_image.size
        
        # 업스케일 후 크기 제한 (메모리 보호)
        max_dimension = 8192  # 최대 8K
        new_width = original_width * scale
        new_height = original_height * scale
        
        if new_width > max_dimension or new_height > max_dimension:
            raise HTTPException(
                status_code=400, 
                detail=f"업스케일 후 이미지 크기가 너무 큽니다. (최대: {max_dimension}x{max_dimension})"
            )
        
        # 고품질 업스케일링 (Lanczos 리샘플링)
        upscaled_image = input_image.resize(
            (new_width, new_height),
            Image.Resampling.LANCZOS
        )
        
        # 이미지 선명도 향상 (UnsharpMask 필터)
        from PIL import ImageFilter
        upscaled_image = upscaled_image.filter(
            ImageFilter.UnsharpMask(radius=1, percent=120, threshold=3)
        )
        
        # PNG로 변환 (최대 품질)
        img_byte_arr = io.BytesIO()
        
        # 원본 포맷 유지 (PNG는 PNG로, JPG는 JPG로)
        output_format = 'PNG' if input_image.mode == 'RGBA' else 'JPEG'
        
        if output_format == 'JPEG':
            # RGB 변환 (JPEG는 RGBA 미지원)
            if upscaled_image.mode in ('RGBA', 'LA', 'P'):
                background = Image.new('RGB', upscaled_image.size, (255, 255, 255))
                if upscaled_image.mode == 'P':
                    upscaled_image = upscaled_image.convert('RGBA')
                background.paste(upscaled_image, mask=upscaled_image.split()[-1] if upscaled_image.mode == 'RGBA' else None)
                upscaled_image = background
            upscaled_image.save(img_byte_arr, format='JPEG', quality=95, optimize=True)
            media_type = "image/jpeg"
            extension = "jpg"
        else:
            upscaled_image.save(img_byte_arr, format='PNG', optimize=True)
            media_type = "image/png"
            extension = "png"
        
        img_byte_arr.seek(0)
        
        return StreamingResponse(
            img_byte_arr,
            media_type=media_type,
            headers={
                "Content-Disposition": f"attachment; filename=upscaled_{scale}x_{file.filename.rsplit('.', 1)[0]}.{extension}"
            },
        )
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"이미지 처리 중 오류 발생: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

