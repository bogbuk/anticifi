import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
  BadRequestException,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import type { FastifyRequest } from 'fastify';

export interface UploadedFile {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  buffer: Buffer;
  size: number;
}

@Injectable()
export class FastifyFileInterceptor implements NestInterceptor {
  constructor(private readonly fieldName: string) {}

  async intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Promise<Observable<any>> {
    const req = context.switchToHttp().getRequest<FastifyRequest>();
    const file = await (req as any).file();

    if (!file) {
      (req as any).uploadedFile = undefined;
      return next.handle();
    }

    if (file.fieldname !== this.fieldName) {
      throw new BadRequestException(
        `Expected file field "${this.fieldName}", got "${file.fieldname}"`,
      );
    }

    const buffer = await file.toBuffer();

    (req as any).uploadedFile = {
      fieldname: file.fieldname,
      originalname: file.filename,
      encoding: file.encoding,
      mimetype: file.mimetype,
      buffer,
      size: buffer.length,
    } satisfies UploadedFile;

    return next.handle();
  }
}

export function FileUpload(fieldName: string) {
  return new FastifyFileInterceptor(fieldName);
}
