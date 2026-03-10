import { Table, Column, Model, DataType, ForeignKey, BelongsTo } from 'sequelize-typescript';
import { User } from '../users/user.model.js';

@Table({ tableName: 'audit_logs', underscored: true, timestamps: true, updatedAt: false })
export class AuditLog extends Model {
  @Column({ type: DataType.UUID, defaultValue: DataType.UUIDV4, primaryKey: true })
  declare id: string;

  @ForeignKey(() => User)
  @Column({ type: DataType.UUID, allowNull: false })
  declare adminId: string;

  @BelongsTo(() => User)
  declare admin: User;

  @Column({ type: DataType.STRING, allowNull: false })
  declare action: string;

  @Column({ type: DataType.STRING, allowNull: true })
  declare targetType: string;

  @Column({ type: DataType.UUID, allowNull: true })
  declare targetId: string;

  @Column({ type: DataType.JSONB, allowNull: true })
  declare details: Record<string, any>;

  @Column({ type: DataType.STRING, allowNull: true })
  declare ipAddress: string;
}