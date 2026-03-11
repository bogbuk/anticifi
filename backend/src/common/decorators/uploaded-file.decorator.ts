import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { UploadedFile } from '../interceptors/file-upload.interceptor.js';

export const UploadedFileParam = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): UploadedFile | undefined => {
    const request = ctx.switchToHttp().getRequest();
    return request.uploadedFile;
  },
);
