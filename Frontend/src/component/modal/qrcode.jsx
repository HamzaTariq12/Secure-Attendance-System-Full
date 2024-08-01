import React, { useState } from 'react'
import { QRCodeSVG } from 'qrcode.react';
import { Box, Container, IconButton  } from '@mui/material';
import Modal from '@mui/material/Modal';
import CloseIcon from '@mui/icons-material/Close';
import KFUEIT from 'assets/logo.png'
import { useNavigate } from 'react-router-dom';
import FullscreenIcon from '@mui/icons-material/Fullscreen';
import { FullScreen, useFullScreenHandle } from "react-full-screen";
const style = {
  position: 'absolute',
  padding: "0px",
  top: '45%',
  left: '50%',
  transform: 'translate(-50%, -50%)',
  width: 500,
  height: 520,
  // bgcolor: '#1976d2',
  // border: '2px solid #000',
  boxShadow: 24,
  p: 4,
};
export default function Qrcode({ open, onClose, qrString }) {
  const handle = useFullScreenHandle();
  const navigate = useNavigate();
  const handleClose = () => {
    onClose();
    // courseClose();
    navigate('/attendance')
  };

  return (
    <>
      <Modal
        open={open}
        aria-labelledby="modal-modal-title"
        aria-describedby="modal-modal-description"
        style={{padding:"0px",margin:"0px"}}
      >    
        <Box>
          <Container sx={{ ...style}} style={{padding:"0px"}}>
            <div style={{ display: "flex", justifyContent: "flex-end",alignItems:"center" }}>
                <IconButton onClick={handle.enter}>
                  <FullscreenIcon style={{color:"white"}} />
                </IconButton>
              {/* )} */}
            <CloseIcon onClick={handleClose} style={{color:"white"}} />
            </div>
            <div>
            <FullScreen handle={handle}>
              <QRCodeSVG
              level='H'
                value={qrString} 
                style={{width:FullScreen ? "100%":"500px",height:FullScreen? "100%":"500px",padding:FullScreen ? "10px":"0px",backgroundColor:"white",color:"black" }}
                imageSettings={{
                  src: KFUEIT,
                  height: 40,
                  width: 40,
                  excavate:true,
                }}
              />
              </FullScreen>
            </div>
          </Container>
        </Box>
      </Modal>
    </>

  )
}
