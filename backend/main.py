from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any
import os

app = FastAPI(
    title="Konditorei API",
    description="Backend API for Konditorei Widget",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class HealthResponse(BaseModel):
    status: str
    message: str
    version: str

class WidgetConfig(BaseModel):
    agent_id: str
    environment: str

@app.get("/", response_model=Dict[str, str])
async def root():
    """Root endpoint"""
    return {"message": "Welcome to Konditorei API"}

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        message="Konditorei API is running",
        version="1.0.0"
    )

@app.get("/api/config", response_model=WidgetConfig)
async def get_widget_config():
    """Get widget configuration"""
    return WidgetConfig(
        agent_id=os.getenv("REACT_APP_WIDGET_AGENT_ID", "agent_6401k3d96afze6cbtcx585yqa3sa"),
        environment=os.getenv("REACT_APP_ENVIRONMENT", "production")
    )

@app.get("/api/status")
async def get_status():
    """Get application status"""
    return {
        "status": "operational",
        "services": {
            "frontend": "running",
            "backend": "running",
            "widget": "active"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

